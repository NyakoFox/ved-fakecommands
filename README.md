# ved-fakecommands

Adds "fake commands", or "fakecommands", which turn into normal commands behind the scenes!
Save some typing, or code-generate entire cutscenes based on your input!

## Download?

Download this repository as a ZIP, and put the folder containing the files into your Ved plugins directory.

## How do I use them?

Using fakecommands are easy, just write a colon, the command name, and any arguments if the command wants them!

```lua
cutscene
untilbars

:reply()
Hi! I'm Viridian!

endcutscene
untilbars
```

Putting this in an internal script should create Viridian's textbox.

## How do I add my own?

Add a file named `fakecommands.lua` in your level's folder.

Fake commands are written in Lua. You register a command by name, and give it a function.

```lua
register_cmd("flash", function(args)
    return {
        "flash(5)",
        "shake(20)",
        "playef(9)",
    }
end)
```

This is a sample command which creates the simplified scripting `flash` command.

### Arguments

Arguments are user-input, so make sure you properly handle them! The `args` table passed into the function contains them.

For example, a `:flash()` with a custom sound argument:

```lua
register_cmd("flash", function(args)
    local commands = {
        "flash(5)",
        "shake(20)"
    }

    if args[1] ~= nil then
        -- If we got a first argument, use it!
        table.insert(commands, "playef(" .. args[1] .. ")")
    else
        -- We didn't get an argument. Use the default!
        table.insert(commands, "playef(9)")
    end

    return commands
end)
```

### Basic Options

Fake commands can have various options, passed in as a third argument to the `register_cmd` function. There is `consumetext` and `color`.

```lua
register_cmd("setroomname",function(args, consumed)
    -- `consumed` is a table, containing the consumed lines of text.
    return {
        "setroomname",
        consumed[1] or "" -- Use the line we captured! If it's nil (there's no next line), use an empty string instead.
    }
end, {
    consumetext = 1, -- Capture one line below the command
    color = "white" -- Highlight it as white
})
```

This example command is just `setroomname`, but it shows off that it should consume a single line below it, and highlight that line as white.

### Dynamic Options

Options can also be functions, which receive any arguments that the command itself receives.

```lua
register_cmd("reply", function(args,consumed)
    -- consumed is the lines of text
    local scr = {}
    table.insert(scr, "squeak(cyan)")
    table.insert(scr, "text(player,0,0," .. #consumed .. ")")
    for i = 1, #consumed do -- Loop through the lines we got.
        table.insert(scr, consumed[i]) -- Insert the line into the script.
    end
    table.insert(scr, "position(center)")
    table.insert(scr, "speak_active")
    table.insert(scr, "endtext")
    return scr
end, {
    consumetext = function(args)
        -- FIRST: Grab the line count the player input in our command
        local lines_to_consume = anythingbutnil0(args[1])
        -- anythingbutnil0 is a helper function which turns any `nil`s (the absence of a value, like if someone didn't pass in the argument) into 0s.

        -- SECOND: Make sure you can't have less than one line...
        if lines_to_consume < 1 then
            lines_to_consume = 1
        end

        return lines_to_consume -- Tell fakecommands that we want to consume the amount of lines the user input, with a minimum of one line!
    end,
    color = "player"
})
```

Tada! Now, `:reply(20)` will take up the next 20 lines, and shove them into our fakecommand! With this, you can make things like custom textboxes!

> [!WARNING]
> This is a very cut down version of the `:reply` fakecommand, solely as an example. Check `fakecommands_defaults.lua` for the real version if required.

### Events

Events are special functions which are executed when certain sections of code are reached.

The events you can use are:

- `preparse` - Happens before the script is parsed for Fake commands, when a script is saved.
- `postparse` - Happens after the script is parsed for Fake commands, when a script is saved.

### Event example

```lua
local my_counter = 0

register_event("preparse", function()
    my_counter = 0 -- Reset the counter when we're about to read the script.
end)

register_cmd("inccounter", function(args)
    my_counter = my_counter + 1
    return {} -- Don't insert any lines!
end)

register_event("postparse", function()
    print("Amount of times :inccounter appeared in the script: " .. my_counter)
end)

```

With these, saving the following script in Ved:

```lua
:inccounter()
:inccounter()
:inccounter()
:inccounter()
:inccounter()
```

...should print out the following text in the console:

```
Amount of times :inccoutner appeared in the script: 5
```

Any time your command may rely on variables which persist between commands, make sure to reset them in `preparse`, or else they'll end up affecting other scripts you open!

## Defaults

Fakecommands comes with a bunch of "default" fakecommands. Below are their usages.

### `:settile(x,y,tile)`

Place a solid "tile" entity at pixel coordinates (not tile coordinates) (x,y). The tile is the tile number from `tiles.png`.

> [!WARNING]
> These are not real tiles -- they are **quicksand entities**. They will **always** render a tile from `tiles.png` (not `tiles2.png`!), and their collision can be destroyed by a moving platform going through it. Additionally, since they are entities (with collision), **be careful with how many you spawn** -- they can cause lag if you spawn too many!

### `:setbgtile(x,y,tile)`

Similar to `:settile`, but they don't have collision.

> [!WARNING]
> These are what `:settile` creates, but the command additionally spawns a (very fast) moving platform on top of them to destroy their collision. This has not been fully tested, and there's a chance the platform may come back on screen after a while. Use with caution.

### `:wait_for_action()`

Wait for the player to press the action button to continue the script. Similar to a textbox.

### `:target(index)`

Sets the "target" to the entity with the given index. Used with [Arbitrary Entity Manipulation](https://vsix.dev/wiki/Guide:Arbitrary_Entity_Manipulation).

### `:fake_death()`

Plays the player death animation and sound.

> [!NOTE]
> As this does not really kill the player, the death count does not increase. Additionally, this does not freeze the player in place.

### `:fake_respawn()`

Plays the player respawn animation.

> [!NOTE]
> The player isn't actually respawning, so their position is not changed at all using this command.

### `:freeze()`

Freezes the player (and enemies) in place.

> [!WARNING]
> The game will unfreeze once there is no script running. Additionally, when the game is frozen, some entities don't update their sprite properly.

### `:unfreeze()`

Undo the effects of `:freeze`.

> [!WARNING]
> Due to how this command works (it runs `gamestate(1003)`, which unfreezes the game and also fades the music in), there is a built-in 1-frame delay. Additionally, the music may be quiet for a single frame before going back to full volume.
> If you are fine with the music fading in, instead call `gamestate(1003)`.

### `:squeak([args])`

If `args` is `off`, further squeaks (including `:say` and `:reply`) will not play. If `args` is `on`, they will start playing again. If `args` is a color, it'll play that color's squeak.

### `:say([lines, [speaker, [position]]])`

Display a textbox with the given lines.

- `lines` is the number of lines in the textbox. Defaults to 1.
- `speaker` is the color of the textbox. Defaults to gray.
- `position` is the position of the textbox. By default, it will appear above the crewmate with the specified color in `speaker`, or if `speaker` isn't passed in or is `terminal`, it will appear in the center of the screen. Possible inputs are:
- - `above` (above the crewmate specified)
- - `below` (below the crewmate specified)
- - `custom` (above the collectible crewmate specified)
- - `belowcustom` (below the collectible crewmate specified)
- - `center` (center of the screen)

Example:

```lua
:say(1)
This is a gray terminal.

:say(2,red,below)
This is Vermilion's textbox, with
two lines. It appears below him.
```

> [!NOTE]
> This may work differently than you may expect if you're coming from simplified scripting as this is not a 1:1 recreation of it.

### `:reply([lines, [position]])`

Display a player textbox with the given lines.

- `lines` is the number of lines in the textbox. Defaults to 1.
- `position` is the position of the textbox. By default, it will appear above the player. Possible inputs are:
- - `above` (above the player)
- - `below` (below the player)
- - `center` (center of the screen)

> [!NOTE]
> This may work differently than you may expect if you're coming from simplified scripting as this is not a 1:1 recreation of it.
