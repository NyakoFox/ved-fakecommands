FAKECOMMANDS = {}
FAKECOMMANDS_EVENTS = {}

FAKECOMMANDS_load()

if puzzle ~= nil then
    PUZZLE_ON_LOAD(function()
        local states = { "maineditor", "scriptlist", "scripteditor" }
        for _, state in ipairs(states) do
            local menu = puzzle(state):submenu("FakeCommands", "fakecommands")
            menu:button("Create Lua file", function()
                if file_exists(getlevelassetsfolder() .. "/fakecommands.lua") then
                    dialog.create("A fakecommands.lua file already exists in this level's assets folder!", DBS.OK)
                    return
                else
                    writelevelfile(getlevelassetsfolder() .. "/fakecommands.lua", [=[
--[[
    Welcome to fakecommands! You can use this file to create level-specific fake commands.

    Here's an example command:

    register_cmd("flash", function(args)
        return {
            "flash(5)",
            "shake(20)",
            "playef(9)",
        }
    end)

    This adds a ":flash()" command, which works like the simplified scripting flash command.

    Further documentation can be found in the GitHub repository: https://github.com/NyakoFox/ved-fakecommands/
]]
]=])
                    dialog.create("fakecommands.lua created in this level's assets folder!", DBS.OK)
                end
            end)
            menu:button("Reload FakeCommands", function()
                FAKECOMMANDS_load(getlevelassetsfolder())
                dialog.create("FakeCommands reloaded!", DBS.OK)
            end)
        end
    end)
end
