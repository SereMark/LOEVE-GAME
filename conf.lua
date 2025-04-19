function love.conf(t)
    t.version = "11.4"                    -- The LÖVE version this game was made for
    t.console = true                      -- Attach a console (Windows only)

    t.window.title = "LÖVE Starter Project" -- The window title
    t.window.icon = nil                   -- Filepath to window icon
    t.window.width = 800                  -- Window width
    t.window.height = 600                 -- Window height
    t.window.minwidth = 800               -- Minimum window width
    t.window.minheight = 600              -- Minimum window height
    t.window.resizable = true             -- Let the window be user-resizable
    t.window.fullscreen = false           -- Enable fullscreen
    t.window.vsync = true                 -- Enable vertical sync
    t.window.msaa = 0                     -- MSAA anti-aliasing level
    
    t.modules.audio = true                -- Enable the audio module
    t.modules.data = true                 -- Enable the data module
    t.modules.event = true                -- Enable the event module
    t.modules.font = true                 -- Enable the font module
    t.modules.graphics = true             -- Enable the graphics module
    t.modules.image = true                -- Enable the image module
    t.modules.joystick = true             -- Enable the joystick module
    t.modules.keyboard = true             -- Enable the keyboard module
    t.modules.math = true                 -- Enable the math module
    t.modules.mouse = true                -- Enable the mouse module
    t.modules.physics = true              -- Enable the physics module
    t.modules.sound = true                -- Enable the sound module
    t.modules.system = true               -- Enable the system module
    t.modules.thread = true               -- Enable the thread module
    t.modules.timer = true                -- Enable the timer module
    t.modules.touch = true                -- Enable the touch module
    t.modules.video = true                -- Enable the video module
    t.modules.window = true               -- Enable the window module
end