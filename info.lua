t = ...  -- Required for this info file to work.

t.shortname = "Fake Commands"  -- The name that will be displayed on the button in the plugins list. Should be no longer than 21 characters, or it will be wider than the button.
t.longname = "Fake Commands"  -- This can be about twice as long
t.author = "NyakoFox"  -- Your name
t.version = "1.2.8"  -- The current version of this plugin, can be anything you want
t.minimumved = "1.11.0"  -- The minimum version of Ved this plugin is designed to work with. If unsure, just use the latest version.
t.description = [[
Write a fake command, which outputs real ones!

:freeze()\G

...turns into...

gamestate¤(§¤1003¤)\CpYp(
delay¤(§¤1§¤)\CpYp(
stopmusic¤()\Cp
resumemusic¤()\Cp]]  -- The description that will be displayed in the plugins list. This uses the help/notepad system, so you can use text formatting here, and even images!
t.overrideinfo = false  -- Set this to true if you want to make your description fully custom and disable the default header with the plugin name, your username and the plugin version at the top. Leave at false if uncertain.
fakecommands_path = t.internal_pluginpath .. "/"
