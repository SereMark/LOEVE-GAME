local State = require("src.states.state")
local Constants = require("src.constants")
local GameState = require("src.states.gamestate")
local Debug = require("src.utils.debug")

local GameOverState = State:new("GameOver")

function GameOverState:init()
    self.options = {
        {text = "RETRY", action = function() self:retry() end},
        {text = "LOAD GAME", action = function() self:loadGame() end},
        {text = "QUIT TO MENU", action = function() self:quitToMenu() end}
    }
    self.selectedOption = 1
    self.score = 0
    self.message = "GAME OVER"
    self.background = nil
    
    -- Particle effect
    self.particles = love.graphics.newParticleSystem(ParticleSystem:createDefaultParticle(), 200)
    self.particles:setParticleLifetime(1, 3)
    self.particles:setEmissionRate(50)
    self.particles:setSizes(2, 4)
    self.particles:setColors(1, 0.3, 0.3, 1, 1, 0.1, 0.1, 0)
    self.particles:setLinearAcceleration(-20, -50, 20, 20)
    self.particles:setPosition(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    self.particles:setEmitterLifetime(1)
    self.particles:stop()
end

function GameOverState:enter(score, message)
    Debug:log("Entered game over state")
    
    -- Take screenshot of current game state
    self.background = love.graphics.newScreenshot()
    
    -- Set game over data
    self.score = score or 0
    self.message = message or "GAME OVER"
    
    -- Play game over sound
    Audio:playSound("game_over")
    
    -- Stop game music and play game over music
    Audio:stopMusic()
    Audio:playMusic("game_over", 0.7, true)
    
    -- Emit particles
    self.particles:setPosition(love.graphics.getWidth() / 2, love.graphics.getHeight() / 2)
    self.particles:emit(200)
    
    -- Create UI elements
    self:createUI()
end

function GameOverState:createUI()
    -- Clear previous UI
    UI:clearElements()
    
    -- Get dimensions
    local width, height = love.graphics.getDimensions()
    
    -- Create panel
    local panelWidth = 400
    local panelHeight = 500
    local panelX = (width - panelWidth) / 2
    local panelY = (height - panelHeight) / 2
    
    local panel = UI:createPanel(panelX, panelY, panelWidth, panelHeight)
    
    -- Create title
    UI:createLabel(width / 2, panelY + 50, self.message, Fonts.large, Constants.COLORS.RED, 6)
    
    -- Create score display
    UI:createLabel(
        width / 2,
        panelY + 120,
        "SCORE: " .. self.score,
        Fonts.medium,
        Constants.COLORS.WHITE,
        6
    )
    
    -- Create buttons
    for i, option in ipairs(self.options) do
        UI:createButton(
            width / 2 - 100,
            panelY + 200 + (i-1) * 60,
            200,
            50,
            option.text,
            option.action,
            6
        )
    end
end

function GameOverState:retry()
    -- Play sound
    Audio:playSound("menu_select")
    
    -- Switch back to play state
    GameState:switch("Play")
end

function GameOverState:loadGame()
    -- Play sound
    Audio:playSound("menu_select")
    
    -- Show load dialog
    local width, height = love.graphics.getDimensions()
    
    -- Get save slots
    local saves = SaveLoad:getSaveSlots()
    
    if #saves == 0 then
        -- No saves found
        local panel = UI:createPanel(width / 2 - 150, height / 2 - 100, 300, 200, 7)
        
        UI:createLabel(
            width / 2,
            height / 2 - 50,
            "No save files found!",
            Fonts.medium,
            Constants.COLORS.WHITE,
            7
        )
        
        UI:createButton(
            width / 2 - 50,
            height / 2 + 20,
            100,
            40,
            "OK",
            function()
                UI:clearElements()
                self:createUI()
            end,
            7
        )
    else
        -- Create save selection panel
        local panelWidth = 400
        local panelHeight = math.min(400, 100 + #saves * 60)
        local panelX = (width - panelWidth) / 2
        local panelY = (height - panelHeight) / 2
        
        local panel = UI:createPanel(panelX, panelY, panelWidth, panelHeight, 7)
        
        UI:createLabel(
            width / 2,
            panelY + 30,
            "Load Game",
            Fonts.medium,
            Constants.COLORS.WHITE,
            7
        )
        
        -- Create save slot buttons
        for i, save in ipairs(saves) do
            local dateStr = os.date("%Y-%m-%d %H:%M", save.timestamp or save.modtime)
            
            UI:createButton(
                panelX + 50,
                panelY + 70 + (i-1) * 60,
                300,
                50,
                save.slot .. " - " .. dateStr,
                function()
                    local success = SaveLoad:loadGame(save.slot)
                    if success then
                        Audio:stopMusic()
                        GameState:switch("Play")
                    else
                        Debug:log("Failed to load game")
                    end
                end,
                7
            )
        end
        
        -- Create back button
        UI:createButton(
            panelX + panelWidth / 2 - 50,
            panelY + panelHeight - 50,
            100,
            40,
            "Back",
            function()
                UI:clearElements()
                self:createUI()
            end,
            7
        )
    end
end

function GameOverState:quitToMenu()
    -- Play sound
    Audio:playSound("menu_back")
    
    -- Stop music
    Audio:stopMusic()
    
    -- Switch to menu
    GameState:switch("Menu")
end

function GameOverState:update(dt)
    -- Update particles
    self.particles:update(dt)
end

function GameOverState:draw()
    -- Draw the screenshot in the background
    if self.background then
        love.graphics.setColor(0.3, 0.3, 0.3, 1)
        love.graphics.draw(self.background)
    end
    
    -- Draw darkening overlay
    love.graphics.setColor(0, 0, 0, 0.8)
    local w,h = love.graphics.getDimensions()
    love.graphics.rectangle("fill", 0, 0, w, h)
    
    -- Draw particles
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.particles)
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

function GameOverState:keypressed(key)
    -- Navigate menu with arrow keys
    if key == "up" then
        self.selectedOption = math.max(1, self.selectedOption - 1)
        Audio:playSound("menu_move")
    elseif key == "down" then
        self.selectedOption = math.min(#self.options, self.selectedOption + 1)
        Audio:playSound("menu_move")
    elseif key == "return" or key == "space" then
        Audio:playSound("menu_select")
        self.options[self.selectedOption].action()
    end
    
    return false
end

function GameOverState:exit()
    -- Free the screenshot memory
    if self.background then
        self.background:release()
        self.background = nil
    end
end

GameOverState:init()

return GameOverState