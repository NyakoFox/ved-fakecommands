function register_cmd(name, func, options)
    for i = #FAKECOMMANDS, 1, -1 do
        if FAKECOMMANDS[i]["name"] == name then
            table.remove(FAKECOMMANDS, i)
        end
    end

    local cmd = {
        name = name,
        func = func,
        options = options or {
            consumetext = 0
        }
    }
    table.insert(FAKECOMMANDS, cmd)
end

function register_event(event,func)
    if FAKECOMMANDS_EVENTS[event] == nil then
        FAKECOMMANDS_EVENTS[event] = {}
    end
    table.insert(FAKECOMMANDS_EVENTS[event], func)
end

function FAKECOMMANDS_event(event_name, ...)
    if FAKECOMMANDS_EVENTS[event_name] == nil then
        return
    end
    for _, func in ipairs(FAKECOMMANDS_EVENTS[event_name]) do
        local success, result = pcall(func, ...)
        if not success then
            FAKECOMMANDS_error(event_name, "event", nil, result)
        end
    end
end

function FAKECOMMANDS_error(command, where, line, error_msg)
    local str = ""

    local event = false

    if where == "event" then
        event = true
        str = "Error in FAKECOMMAND EVENT \"" .. command .. "\""
    elseif where == "command" then
        str = "Error in FAKECOMMAND \"" .. command .. "\""
    else
        str = "Error in FAKECOMMAND \"" .. command .. "\"'s \"" .. where .. "\" function"
    end

    -- Seems like Ved's dialog boxes don't wrap text, so let's just... trim the error? I guess?
    local trimmed_error = ""
    local colon_pos = string.find(error_msg, ".lua:")
    if colon_pos ~= nil then
        trimmed_error = "Line " .. string.sub(error_msg, colon_pos + 5)
    else
        trimmed_error = error_msg
    end

    if event then
        str = str .. ":\n\n" .. trimmed_error .. "\n\nEvent: " .. command
    else
        str = str .. ":\n\n" .. trimmed_error .. "\n\nCommand: " .. line .. "\n\nThe affected lines have been ignored."
    end

    dialog.create(str, DBS.OK)
    cons(str)
end

function FAKECOMMANDS_DOFILE_SAFE(path)
    local success, result = pcall(dofile, path)
    return success, result
end

function FAKECOMMANDS_load(levelassetsfolder)
    FAKECOMMANDS = {}
    FAKECOMMANDS_EVENTS = {}

    if not love.filesystem.exists("fakecommands.lua") then
        local success, message = love.filesystem.write("fakecommands.lua", "-- See fakecommands_defaults.lua in the plugin directory for examples.\n-- Make sure to check arguments for nil!\n-- Per-level fakecommands can also be made now, create fakecommands.lua in your level's assets folder")
    end

    dofile(love.filesystem.getSaveDirectory() .. "/" .. fakecommands_path .. "fakecommands_defaults.lua")

    local success, result = FAKECOMMANDS_DOFILE_SAFE(love.filesystem.getSaveDirectory() .. "/fakecommands.lua")
    if success then
        cons("Loaded user fakecommands")
    else
        cons("Error loading user fakecommands")
        cons(result)
    end

    if levelassetsfolder ~= nil then
        local success, result = FAKECOMMANDS_DOFILE_SAFE(levelassetsfolder .. "/fakecommands.lua")
        if success then
            cons("Loaded level-specific fakecommands")
        else
            cons("Error loading level-specific fakecommands")
            cons(result)
        end
    end
end
