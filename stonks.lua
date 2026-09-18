_addon.name     = 'Stonks'
_addon.author   = 'Chocopon'
_addon.version  = '1.1'
_addon.commands = {'stonks'}

local has_lfs, lfs = pcall(require, 'lfs')

local LEDGER_DIR = windower.addon_path .. 'data/ledger/'

local function dir_exists(path)
    if has_lfs then
        local attr = lfs.attributes(path)
        return attr and attr.mode == 'directory'
    end

    if windower and type(windower.dir_exists) == 'function' then
        local ok, result = pcall(windower.dir_exists, path)
        return ok and result == true
    end

    return false
end

local function ensure_dir(path)
    if dir_exists(path) then
        return true
    end

    if has_lfs then
        local ok = lfs.mkdir(path)
        if ok or dir_exists(path) then
            return true
        end
    end

    if windower and type(windower.create_dir) == 'function' then
        local ok = pcall(windower.create_dir, path)
        if ok and dir_exists(path) then
            return true
        end
    end

    return dir_exists(path)
end

local function init_paths()
    ensure_dir(windower.addon_path .. 'data')
    return ensure_dir(LEDGER_DIR)
end

local function fmt(n)
    n = math.floor(tonumber(n) or 0)
    local s = tostring(n)
    local sign, int = s:match('^([%-]?)(%d+)$')
    int = int:reverse():gsub('(%d%d%d)', '%1,'):reverse():gsub('^,', '')
    return sign .. int
end

local function live_gil()
    local items = windower.ffxi.get_items()
    return (items and items.gil) or 0
end

local function who()
    local p = windower.ffxi.get_player()
    return (p and p.name) or '??'
end

local function safe_name(name)
    return tostring(name):gsub('[^%w%-_]', '_')
end

local function record_path(name)
    return ('%s%s.dat'):format(LEDGER_DIR, safe_name(name))
end

local function write_record(name, gil, ts)
    if not init_paths() then
        return false, 'Unable to initialize ledger directory.'
    end

    local target = record_path(name)
    local temp = target .. '.tmp'

    local f, err = io.open(temp, 'w')
    if not f then
        return false, err or 'open failed'
    end

    f:write(('name=%s\ngil=%d\nts=%d\n'):format(name, gil, ts))
    f:close()

    os.remove(target)
    local ok, rename_err = os.rename(temp, target)
    if not ok then
        os.remove(temp)
        return false, rename_err or 'rename failed'
    end

    return true
end

local function load_record_from_file(path)
    local f, open_err = io.open(path, 'r')
    if not f then
        return nil, open_err
    end
    local blob = f:read('*a')
    f:close()

    local rec = {}
    for line in blob:gmatch('[^\r\n]+') do
        local k, v = line:match('^([^=]+)=(.*)$')
        if k and v then
            rec[k] = v
        end
    end
    rec.name = tostring(rec.name or '')
    rec.gil = tonumber(rec.gil) or 0
    rec.ts = tonumber(rec.ts) or 0

    if rec.name == '' then
        return nil, 'missing name'
    end

    return rec
end

local function iter_ledger_files()
    local files = {}

    if has_lfs then
        for file in lfs.dir(LEDGER_DIR) do
            if file ~= '.' and file ~= '..' and file:sub(-4) == '.dat' then
                files[#files + 1] = file
            end
        end
        return files, nil
    end

    if windower and type(windower.get_dir) == 'function' then
        local ok, entries = pcall(windower.get_dir, LEDGER_DIR)
        if not ok or type(entries) ~= 'table' then
            return nil, 'Unable to read ledger directory.'
        end

        for _, entry in ipairs(entries) do
            local name
            if type(entry) == 'string' then
                name = entry
            elseif type(entry) == 'table' then
                name = entry.name or entry.file or entry.filename or entry[1]
            end

            if type(name) == 'string' and name:sub(-4) == '.dat' then
                files[#files + 1] = name
            end
        end

        return files, nil
    end

    return nil, 'Unable to scan ledger directory (missing lfs and get_dir).'
end

local function load_all_records()
    local out = {}
    if not init_paths() then
        return out, 'Unable to initialize ledger directory.'
    end

    local files, list_err = iter_ledger_files()
    if not files then
        return out, list_err or 'Unable to scan ledger directory.'
    end

    for _, file in ipairs(files) do
        local path = LEDGER_DIR .. file
        local rec = load_record_from_file(path)
        if rec then
            out[rec.name] = rec
        end
    end

    return out, nil
end

local function save_self()
    local name = who()
    if not name or name == '??' then
        return false, 'Character name unavailable.'
    end
    return write_record(name, live_gil(), os.time())
end

local function find_entry(name_query)
    if not name_query or name_query == '' then return nil, nil end
    local target = name_query:lower()
    local records = select(1, load_all_records())
    for name, rec in pairs(records) do
        if tostring(name):lower() == target then
            return name, rec
        end
    end
    return nil, nil
end

windower.register_event('addon command', function(arg1)
    arg1 = arg1 and arg1:lower() or nil

    if not arg1 or arg1 == '' then
        local name = who()
        local g = live_gil()
        save_self()
        windower.add_to_chat(207, ('%s has %s gil.'):format(name, fmt(g)))
        return
    end

    if arg1 == 'save' then
        local ok, err = save_self()
        windower.add_to_chat(207, ok and '[Stonks] Saved.' or ('[Stonks] Save failed: ' .. tostring(err)))
        return
    end

    if arg1 == 'all' then
        save_self()
        local records, scan_err = load_all_records()
        if scan_err then
            windower.add_to_chat(123, '[Stonks] ' .. scan_err)
            return
        end

        local total, lines = 0, {}
        for name, rec in pairs(records) do
            local g = tonumber(rec.gil) or 0
            total = total + g
            table.insert(lines, ('  %s: %s'):format(name, fmt(g)))
        end
        table.sort(lines)

        windower.add_to_chat(207, '[Stonks] Gil per character (data/ledger/*.dat):')
        for _, line in ipairs(lines) do
            windower.add_to_chat(207, line)
        end
        windower.add_to_chat(207, ('Combined Total: %s gil.'):format(fmt(total)))
        return
    end

    if arg1 == 'ls' then
        local records, scan_err = load_all_records()
        if scan_err then
            windower.add_to_chat(123, '[Stonks] ' .. scan_err)
            return
        end

        local names = {}
        for name in pairs(records) do
            table.insert(names, name)
        end
        table.sort(names)

        windower.add_to_chat(207, '[Stonks] Known characters:')
        for _, n in ipairs(names) do
            windower.add_to_chat(207, '  ' .. n)
        end
        return
    end

    local key, rec = find_entry(arg1)
    if rec then
        windower.add_to_chat(207, ('%s has %s gil.'):format(key, fmt(rec.gil)))
    else
        windower.add_to_chat(207, ('[Stonks] No entry for "%s". Have that character run //stonks once.'):format(arg1))
    end
end)
