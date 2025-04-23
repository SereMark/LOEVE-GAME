--[[
    conf.lua
    LÖVE Configuration file
]]--

function love.conf(t)
    -- Game identity information
    t.identity = "loeve-game"    -- The name of the save directory
    t.version = "11.5"           -- LÖVE version this game was made for
    t.console = true             -- Enable console for debug outputs
    
    -- Window configuration
    t.window.title = "LOEVE Game"-- The window title
    t.window.width = 1280        -- Window width
    t.window.height = 720        -- Window height
    t.window.resizable = true    -- Allow window resizing
    t.window.vsync = 1           -- Vertical sync mode (1 = on)
    
    -- Required modules
    t.modules.event = true       -- Required for input handling
    t.modules.font = true        -- Required for text rendering
    t.modules.graphics = true    -- Required for all rendering
    t.modules.keyboard = true    -- Required for keyboard input
    t.modules.math = true        -- Required for calculations
    t.modules.mouse = true       -- Required for mouse input
    t.modules.system = true      -- Required for system access
    t.modules.timer = true       -- Required for game loop
    t.modules.window = true      -- Required for window management
end