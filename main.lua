io.stdout:setvbuf("no")  -- Immediately flush print output (useful for debugging)

-- Global variables
Class = require("libs.class")
Constants = require("src.constants")
Helpers = require("src.utils.helpers")
Debug = require("src.utils.debug")
GameState = require("src.states.gamestate")
Assets = require("src.managers.assets")
Audio = require("src.managers.audio")
Input = require("src.managers.input")
SaveLoad = require("src.managers.saveload")
Camera = require("src.systems.camera")
Physics = require("src.systems.physics")
ParticleSystem = require("src.systems.particles")
UI = require("src.ui.ui")

-- Global fonts
Fonts = {
    small = nil,
    medium = nil,
    large = nil,
    title = nil
}

-- Love callbacks
function love.load()
    -- Set random seed
    math.randomseed(os.time())
    
    -- Set default filter mode
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    -- Load fonts
    Fonts.small = love.graphics.newFont("assets/fonts/pixel.ttf", 16)
    Fonts.medium = love.graphics.newFont("assets/fonts/pixel.ttf", 24)
    Fonts.large = love.graphics.newFont("assets/fonts/pixel.ttf", 32)
    Fonts.title = love.graphics.newFont("assets/fonts/pixel.ttf", 48)
    
    -- Initialize systems
    Assets:init()
    Audio:init()
    Input:init()
    SaveLoad:init()
    Physics:init()
    ParticleSystem:init()
    UI:init()
    Camera:init()
    
    -- Load game states
    local SplashState = require("src.states.splashstate")
    local MenuState = require("src.states.menustate")
    local OptionsState = require("src.states.optionsstate")
    local PlayState = require("src.states.playstate")
    local PauseState = require("src.states.pausestate")
    local GameOverState = require("src.states.gameoverstate")
    
    -- Register states
    GameState:register("Splash", SplashState)
    GameState:register("Menu", MenuState)
    GameState:register("Options", OptionsState)
    GameState:register("Play", PlayState)
    GameState:register("Pause", PauseState)
    GameState:register("GameOver", GameOverState)
    
    -- Start with the splash state
    GameState:switch("Splash")
    
    Debug:log("Game initialized")
end

function love.update(dt)
    -- Cap delta time to prevent physics issues
    dt = math.min(dt, 1/30)
    
    -- Update input manager first
    Input:update(dt)
    
    -- Update current game state
    GameState:update(dt)
    
    -- Update global systems
    Audio:update(dt)
    ParticleSystem:update(dt)
    Physics:update(dt)
    Camera:update(dt)
    
    -- Update UI
    UI:update(dt)
end

function love.draw()
    -- Begin camera transformation
    Camera:attach()
    
    -- Draw current game state
    GameState:draw()
    
    -- Draw particle effects
    ParticleSystem:draw()
    
    -- End camera transformation
    Camera:detach()
    
    -- Draw UI (not affected by camera)
    UI:draw()
    
    -- Draw debug info (after everything else)
    Debug:draw()
end

function love.keypressed(key)
    -- Handle input
    Input:keypressed(key)
    
    -- Global key handling
    if key == "f1" then
        Debug:toggle()
    elseif key == "f11" then
        local fullscreen = not love.window.getFullscreen()
        love.window.setFullscreen(fullscreen)
        Debug:log("Fullscreen: " .. tostring(fullscreen))
        -- force camera to recalculate center immediately
        Camera:resize(love.graphics.getDimensions())
    elseif key == "f5" and Constants.GAME.DEBUG then
        -- Reload the game (during development)
        love.event.quit("restart")
    end
    
    -- Pass event to game state
    GameState:keypressed(key)
    
    -- Pass to UI
    UI:keypressed(key)
end

function love.keyreleased(key)
    Input:keyreleased(key)
    GameState:keyreleased(key)
    UI:keyreleased(key)
end

function love.mousepressed(x, y, button)
    Input:mousepressed(x, y, button)
    GameState:mousepressed(x, y, button)
    UI:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    Input:mousereleased(x, y, button)
    GameState:mousereleased(x, y, button)
    UI:mousereleased(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
    Input:mousemoved(x, y, dx, dy)
    GameState:mousemoved(x, y, dx, dy)
    UI:mousemoved(x, y, dx, dy)
end

function love.wheelmoved(x, y)
    Input:wheelmoved(x, y)
    GameState:wheelmoved(x, y)
    UI:wheelmoved(x, y)
end

function love.gamepadpressed(joystick, button)
    Input:gamepadpressed(joystick, button)
    GameState:gamepadpressed(joystick, button)
end

function love.gamepadreleased(joystick, button)
    Input:gamepadreleased(joystick, button)
    GameState:gamepadreleased(joystick, button)
end

function love.resize(w, h)
    Camera:resize(w, h)
    GameState:resize(w, h)
    UI:resize(w, h)
    Debug:log("Window resized to " .. w .. "x" .. h)
end

function love.focus(focused)
    GameState:focus(focused)
    if not focused then
        -- Automatically pause the game when window loses focus
        if GameState.current and GameState.current.name == "Play" then
            GameState:switch("Pause")
        end
    end
end

function love.quit()
    -- Perform any cleanup before shutting down
    SaveLoad:saveSettings()
    Debug:log("Game is shutting down...")
    return false -- Allow the game to close
end