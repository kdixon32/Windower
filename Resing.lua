_addon.name = 'Resing'
_addon.author = 'OpenAI Codex'
_addon.version = '1.3.0'
_addon.commands = {'resing'}

require('strings')
require('tables')
require('coroutine')

local res = require('resources')
local config = require('config')

local IPC_PREFIX = 'RESING_V1'
local RESPONSE_TIMEOUT = 3
local NIGHTINGALE_BUFF_ID = 347
local MINIMUM_CAST_DELAY = 0.5
local AMBIGUOUS_FAMILIES = {
    [215] = true, -- Etude does not reveal which stat.
    [216] = true, -- Carol does not reveal which element.
}

local defaults = {
    bard = '',
    normal_timing = 0.80,
    nightingale_timing = 0.50,
}

local settings = config.load(defaults)
local pending = nil
local pending_route = nil
local exact_history = {}
local cast_queue = {}
local cast_queue_token = 0
local cast_queue_running = false

local function chat(message)
    windower.add_to_chat(207, 'Resing: '..message)
end

local function player()
    return windower.ffxi.get_player()
end

local function split_pipe(message)
    local fields = {}
    for field in (message..'|'):gmatch('(.-)|') do
        fields[#fields + 1] = field
    end
    return fields
end

local function song_name(spell)
    return spell.en or spell.name
end

local function is_party_song(spell)
    return spell
        and spell.type == 'BardSong'
        and spell.status
        and spell.targets
        and spell.targets:contains('Self')
end

local function local_buff_csv()
    local current = player()
    local buffs = {}

    if current and current.buffs then
        for _, buff_id in ipairs(current.buffs) do
            if buff_id and buff_id ~= 255 then
                buffs[#buffs + 1] = tostring(buff_id)
            end
        end
    end

    return table.concat(buffs, ',')
end

local function parse_buff_counts(csv)
    local counts = {}

    for value in csv:gmatch('[^,]+') do
        local buff_id = tonumber(value)
        if buff_id then
            counts[buff_id] = (counts[buff_id] or 0) + 1
        end
    end

    return counts
end

local function remember_exact_song(spell_id)
    local spell = res.spells[spell_id]
    if not is_party_song(spell) or not AMBIGUOUS_FAMILIES[spell.status] then
        return
    end

    local family_history = exact_history[spell.status] or {}
    for index = #family_history, 1, -1 do
        if family_history[index] == spell_id then
            table.remove(family_history, index)
        end
    end
    family_history[#family_history + 1] = spell_id
    exact_history[spell.status] = family_history
end

local function exact_song_csv(buff_counts)
    local spell_ids = {}

    for status, count in pairs(buff_counts) do
        local family_history = exact_history[status]
        if AMBIGUOUS_FAMILIES[status] and family_history then
            local first = math.max(1, #family_history - count + 1)
            for index = first, #family_history do
                spell_ids[#spell_ids + 1] = tostring(family_history[index])
            end
        end
    end

    return table.concat(spell_ids, ',')
end

local function parse_exact_songs(csv)
    local exact = {}

    for value in csv:gmatch('[^,]+') do
        local spell_id = tonumber(value)
        local spell = spell_id and res.spells[spell_id]
        if is_party_song(spell) and AMBIGUOUS_FAMILIES[spell.status] then
            exact[spell.status] = exact[spell.status] or {}
            exact[spell.status][#exact[spell.status] + 1] = spell
        end
    end

    return exact
end

local function song_family_names(buff_counts)
    local families = {}

    for status, count in pairs(buff_counts) do
        local has_party_song = false
        for _, spell in pairs(res.spells) do
            if is_party_song(spell) and spell.status == status then
                has_party_song = true
                break
            end
        end

        if has_party_song then
            local buff = res.buffs[status]
            local family = buff and (buff.en or buff.name) or tostring(status)
            families[#families + 1] = family..' x'..tostring(count)
        end
    end

    table.sort(families)
    return families
end

local function bard_level(spell)
    return spell.levels and spell.levels[10] or -1
end

local function select_highest_songs(buff_counts, exact_songs)
    local known_spells = windower.ffxi.get_spells() or {}
    local candidates = {}
    local selected = {}
    local missing = {}
    local guessed = {}

    exact_songs = exact_songs or {}

    for spell_id, spell in pairs(res.spells) do
        if is_party_song(spell) and buff_counts[spell.status] and known_spells[spell_id] then
            candidates[spell.status] = candidates[spell.status] or {}
            candidates[spell.status][#candidates[spell.status] + 1] = spell
        end
    end

    for status, count in pairs(buff_counts) do
        local buff = res.buffs[status]
        local family = buff and (buff.en or buff.name)
        local family_candidates = candidates[status]

        if family and family_candidates then
            table.sort(family_candidates, function(left, right)
                local left_level = bard_level(left)
                local right_level = bard_level(right)
                return left_level == right_level and left.id > right.id or left_level > right_level
            end)

            local chosen = {}
            local chosen_ids = {}
            local tracked = exact_songs[status] or {}

            if AMBIGUOUS_FAMILIES[status] then
                for _, spell in ipairs(tracked) do
                    if known_spells[spell.id] and not chosen_ids[spell.id] and #chosen < count then
                        chosen[#chosen + 1] = spell
                        chosen_ids[spell.id] = true
                    end
                end
            end

            for _, spell in ipairs(family_candidates) do
                if #chosen >= count then
                    break
                end
                if not chosen_ids[spell.id] then
                    chosen[#chosen + 1] = spell
                    chosen_ids[spell.id] = true
                end
            end

            if AMBIGUOUS_FAMILIES[status] and #tracked < count then
                guessed[#guessed + 1] = family..' x'..tostring(count - #tracked)
            end

            if AMBIGUOUS_FAMILIES[status] and #tracked > 0 then
                for _, spell in ipairs(chosen) do
                    selected[#selected + 1] = spell
                end
            else
                for index = #chosen, 1, -1 do
                    -- Cast lower selected tiers first so the highest tier is applied last.
                    selected[#selected + 1] = chosen[index]
                end
            end
            if #chosen < count then
                missing[#missing + 1] = family..' x'..tostring(count - #chosen)
            end
        elseif family then
            -- Only report missing song families, not unrelated buffs.
            local has_party_song = false
            for _, spell in pairs(res.spells) do
                if is_party_song(spell) and spell.status == status then
                    has_party_song = true
                    break
                end
            end
            if has_party_song then
                missing[#missing + 1] = family..' x'..tostring(count)
            end
        end
    end

    return selected, missing, guessed
end

local function has_buff(buff_id)
    local current = player()
    if not current or not current.buffs then
        return false
    end

    for _, active_buff in ipairs(current.buffs) do
        if active_buff == buff_id then
            return true
        end
    end
    return false
end

local function queue_delay(spell)
    local timing = has_buff(NIGHTINGALE_BUFF_ID) and settings.nightingale_timing or settings.normal_timing
    return math.max(MINIMUM_CAST_DELAY, (spell.cast_time or 8) * timing)
end

local function stop_cast_queue(message)
    cast_queue = {}
    cast_queue_token = cast_queue_token + 1
    cast_queue_running = false
    if message then
        chat(message)
    end
end

local function process_cast_queue(token)
    if token ~= cast_queue_token then
        return
    end
    if #cast_queue == 0 then
        cast_queue_running = false
        chat('Finished refreshing songs.')
        return
    end

    local spell = table.remove(cast_queue, 1)
    local name = song_name(spell)
    local delay = queue_delay(spell)
    local mode = has_buff(NIGHTINGALE_BUFF_ID) and 'Nightingale' or 'normal'

    chat('Casting '..name..'; next song in '..('%.2f'):format(delay)..'s ('..mode..' timing).')
    windower.send_command('input /ma "'..name..'" <me>')
    coroutine.schedule(function()
        process_cast_queue(token)
    end, delay)
end

local function cast_songs(target_name, songs, missing, guessed)
    local names = {}

    for _, spell in ipairs(songs) do
        local name = song_name(spell)
        names[#names + 1] = name
    end

    if #missing > 0 then
        chat('Could not identify: '..table.concat(missing, ', ')..'.')
    end
    if #guessed > 0 then
        chat('No exact record for '..table.concat(guessed, ', ')..'; using highest-tier fallback.')
    end
    if #songs == 0 then
        chat('No accurately identifiable active song families on '..target_name..' to refresh.')
        return
    end
    if cast_queue_running then
        chat('A song refresh is already running. Use //resing cancel before starting another.')
        return
    end

    chat('Refreshing '..table.concat(names, ', ')..' for the nearby party, based on '..target_name..'.')
    cast_queue = songs
    cast_queue_token = cast_queue_token + 1
    cast_queue_running = true
    process_cast_queue(cast_queue_token)
end

local function request_target_buffs(target_name)
    local current = player()
    if not current then
        chat('You must be logged in.')
        return false
    end
    if current.main_job_id ~= 10 then
        chat('Run this command on the bard that should refresh the party songs.')
        return false
    end
    if cast_queue_running then
        chat('A song refresh is already running. Use //resing cancel before starting another.')
        return false
    end
    if pending then
        chat('Already waiting for '..pending.target..' to report its buffs.')
        return false
    end
    if target_name:lower() == current.name:lower() then
        local buff_counts = parse_buff_counts(local_buff_csv())
        local songs, missing, guessed = select_highest_songs(buff_counts, parse_exact_songs(exact_song_csv(buff_counts)))
        cast_songs(current.name, songs, missing, guessed)
        return true
    end

    local nonce = current.id..'-'..tostring(os.time())..'-'..tostring(math.random(100000, 999999))
    pending = {
        nonce = nonce,
        target = target_name,
        requested_at = os.clock(),
    }

    windower.send_ipc_message(table.concat({
        IPC_PREFIX,
        'REQUEST',
        nonce,
        current.name,
        target_name,
    }, '|'))

    coroutine.schedule(function()
        if pending and pending.nonce == nonce and os.clock() - pending.requested_at >= RESPONSE_TIMEOUT then
            chat('No local buff response from '..target_name..'. Make sure Resing is loaded on that character.')
            pending = nil
        end
    end, RESPONSE_TIMEOUT)

    return true
end

local function configured_bard()
    return settings.bard and settings.bard:trim() or ''
end

local function route_to_bard(target_name)
    local current = player()
    if not current then
        chat('You must be logged in.')
        return
    end

    local bard = configured_bard()
    if bard == '' then
        if current.main_job_id == 10 then
            request_target_buffs(target_name)
        else
            chat('No bard configured. Use //resing bard <character>.')
        end
        return
    end

    if bard:lower() == current.name:lower() then
        request_target_buffs(target_name)
        return
    end

    if pending_route then
        chat('Already waiting for '..pending_route.bard..' to accept a request.')
        return
    end

    local nonce = current.id..'-'..tostring(os.time())..'-'..tostring(math.random(100000, 999999))
    pending_route = {
        nonce = nonce,
        bard = bard,
        target = target_name,
    }

    windower.send_ipc_message(table.concat({
        IPC_PREFIX,
        'BARD_REQUEST',
        bard,
        current.name,
        target_name,
        nonce,
    }, '|'))

    coroutine.schedule(function()
        if pending_route and pending_route.nonce == nonce then
            chat('No response from configured bard '..bard..'. Make sure Resing is loaded on that character.')
            pending_route = nil
        end
    end, RESPONSE_TIMEOUT)
end

local function set_bard(name)
    settings.bard = name or ''
    config.save(settings, 'all')
    windower.send_ipc_message(table.concat({
        IPC_PREFIX,
        'SET_BARD',
        settings.bard,
    }, '|'))

    if settings.bard == '' then
        chat('Configured bard cleared.')
    else
        chat('Configured bard set to '..settings.bard..'.')
    end
end

windower.register_event('ipc message', function(message)
    if not message:startswith(IPC_PREFIX..'|') then
        return
    end

    local fields = split_pipe(message)
    local current = player()
    if not current then
        return
    end

    if fields[2] == 'SET_BARD' then
        settings.bard = fields[3] or ''
    elseif fields[2] == 'SET_TIMING' then
        local mode = fields[3]
        local value = tonumber(fields[4])
        if value and (mode == 'normal' or mode == 'nightingale') then
            settings[mode..'_timing'] = value
        end
    elseif fields[2] == 'BARD_REQUEST' then
        local bard = fields[3]
        local requester = fields[4]
        local target = fields[5]
        local nonce = fields[6]

        if bard and bard:lower() == current.name:lower() then
            local accepted = request_target_buffs(target)
            windower.send_ipc_message(table.concat({
                IPC_PREFIX,
                'BARD_ACK',
                requester,
                current.name,
                target,
                nonce,
                accepted and 'yes' or 'no',
            }, '|'))
        end
    elseif fields[2] == 'BARD_ACK' then
        local requester = fields[3]
        local bard = fields[4]
        local target = fields[5]
        local nonce = fields[6]
        local accepted = fields[7] == 'yes'

        if pending_route and requester:lower() == current.name:lower() and nonce == pending_route.nonce then
            pending_route = nil
            if accepted then
                chat(bard..' accepted the request to refresh songs based on '..target..'.')
            else
                chat(bard..' could not accept the request.')
            end
        end
    elseif fields[2] == 'REQUEST' then
        local nonce = fields[3]
        local requester = fields[4]
        local target = fields[5]

        if target and target:lower() == current.name:lower() then
            windower.send_ipc_message(table.concat({
                IPC_PREFIX,
                'RESPONSE',
                nonce,
                requester,
                current.name,
                local_buff_csv(),
                exact_song_csv(parse_buff_counts(local_buff_csv())),
            }, '|'))
        end
    elseif fields[2] == 'RESPONSE' then
        local nonce = fields[3]
        local requester = fields[4]
        local target = fields[5]
        local buffs = fields[6] or ''
        local exact = fields[7] or ''

        if pending and nonce == pending.nonce and requester:lower() == current.name:lower() then
            pending = nil
            local songs, missing, guessed = select_highest_songs(parse_buff_counts(buffs), parse_exact_songs(exact))
            cast_songs(target, songs, missing, guessed)
        end
    end
end)

windower.register_event('action', function(action)
    if action.category ~= 4 then
        return
    end

    local current = player()
    local spell = res.spells[action.param]
    if not current or not is_party_song(spell) or not AMBIGUOUS_FAMILIES[spell.status] then
        return
    end

    for _, target in ipairs(action.targets) do
        local result = target.actions and target.actions[1]
        if target.id == current.id and result and result.param == spell.status then
            remember_exact_song(spell.id)
            return
        end
    end
end)

windower.register_event('addon command', function(command, ...)
    command = command and command:lower() or 'help'

    if command == 'help' then
        chat('//resing <character> - ask the configured bard to refresh that character\'s active songs.')
        chat('//resing bard <character> - save the bard that should perform routed requests.')
        chat('//resing bard clear - clear the configured bard.')
        chat('//resing buffs - show this character\'s locally detected song families.')
        chat('//resing exact - show exact Carol and Etude variants learned from casts on this character.')
        chat('//resing cancel - cancel a pending local-buff request.')
        chat('//resing timing - show normal and Nightingale queue timing percentages.')
        chat('//resing timing normal|nightingale <percent> - change and save queue timing.')
    elseif command == 'buffs' then
        local families = song_family_names(parse_buff_counts(local_buff_csv()))
        chat(#families > 0 and 'Local song families: '..table.concat(families, ', ') or 'No local song families detected.')
    elseif command == 'exact' then
        local buff_counts = parse_buff_counts(local_buff_csv())
        local tracked = parse_exact_songs(exact_song_csv(buff_counts))
        local names = {}
        for _, spells in pairs(tracked) do
            for _, spell in ipairs(spells) do
                names[#names + 1] = song_name(spell)
            end
        end
        table.sort(names)
        chat(#names > 0 and 'Tracked exact ambiguous songs: '..table.concat(names, ', ') or 'No active Carol or Etude variants have been observed yet.')
    elseif command == 'bard' then
        local name = (...)
        if not name then
            local bard = configured_bard()
            chat(bard ~= '' and 'Configured bard: '..bard..'.' or 'No bard configured.')
        elseif name:lower() == 'clear' or name:lower() == 'none' then
            set_bard('')
        else
            set_bard(name)
        end
    elseif command == 'cancel' then
        pending = nil
        pending_route = nil
        stop_cast_queue('Pending request and song queue cancelled.')
    elseif command == 'timing' or command == 'delay' then
        local mode, value = ...
        if not mode then
            chat(('Timing: normal %.0f%%, Nightingale %.0f%%.'):format(settings.normal_timing * 100, settings.nightingale_timing * 100))
            return
        end

        mode = mode:lower()
        value = tonumber(value)
        if mode ~= 'normal' and mode ~= 'nightingale' then
            chat('Use //resing timing normal|nightingale <percent>.')
            return
        end
        if not value or value < 1 or value > 100 then
            chat('Provide a timing percentage from 1 to 100.')
            return
        end

        settings[mode..'_timing'] = value / 100
        config.save(settings, 'all')
        windower.send_ipc_message(table.concat({
            IPC_PREFIX,
            'SET_TIMING',
            mode,
            tostring(settings[mode..'_timing']),
        }, '|'))
        chat(mode..' timing set to '..tostring(value)..'%.')
    else
        route_to_bard(command)
    end
end)
