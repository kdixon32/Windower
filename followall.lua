_addon.name = 'followall'
_addon.author = 'Chocopon'
_addon.version = '1.0'
_addon.commands = {'followall'}

windower.register_event('addon command', function(...)
    local args = {...}
    local target = args[1]
    if not target or target == '' then
        local me = windower.ffxi.get_player()
        if not me or not me.name then
            windower.add_to_chat(123, '[followall] Could not determine player name.')
            return
        end
        target = me.name
    end
    windower.send_command(('send @others input /follow %s'):format(target))
end)