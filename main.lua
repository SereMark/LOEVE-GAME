io.stdout:setvbuf("no")  -- Immediately flush print output (useful for debugging)

-- Global variables
Class = require("libs.class")
Constants = require("src.constants")
Helpers = require("src.utils.helpers")
Debug = require("src.utils.debug")
GameState = require("src.states.gamestate")

-- Global fonts
Fonts = {
    small = nil,
    medium = nil,
    large = nil
}

-- Love callbacks
function love.load()
    -- Set random seed
    math.randomseed(os.time())
    
    -- Load fonts
    Fonts.small = love.graphics.newFont(12)
    Fonts.medium = love.graphics.newFont(24)
    Fonts.large = love.graphics.newFont(36)
    
    -- Load game states
    local MenuState = require("src.states.menustate")
    local PlayState = require("src.states.playstate")
    
    -- Register states
    GameState:register("Menu", MenuState)
    GameState:register("Play", PlayState)
    
    -- Start with the menu state
    GameState:switch("Menu")
    
    Debug:log("Game initialized")
end

function love.update(dt)
    GameState:update(dt)
end

function love.draw()
    GameState:draw()
    
    -- Draw debug info
    Debug:draw()
end

function love.keypressed(key)
    -- Global key handling
    if key == "f1" then
        Debug:toggle()
    elseif key == "f11" then
        local fullscreen = not love.window.getFullscreen()
        love.window.setFullscreen(fullscreen)
        Debug:log("Fullscreen: " .. tostring(fullscreen))
    elseif key == "f5" then
        -- Reload the game (during development)
        love.event.quit("restart")
    end
    
    -- Pass event to game state
    GameState:keypressed(key)
end

function love.keyreleased(key)
    GameState:keyreleased(key)
end

function love.mousepressed(x, y, button)
    GameState:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    GameState:mousereleased(x, y, button)
end

function love.resize(w, h)
    GameState:resize(w, h)
    Debug:log("Window resized to " .. w .. "x" .. h)
end

function love.quit()
    Debug:log("Game is shutting down...")
    return false -- Allow the game to close
end