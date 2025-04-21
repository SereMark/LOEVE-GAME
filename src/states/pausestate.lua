local State     = require("src.states.state")
local Constants = require("src.constants")
local GameState = require("src.states.gamestate")
local Debug     = require("src.utils.debug")

local PauseState = State:new("Pause")

function PauseState:init()
    self.options = {
        { text = "RESUME",    action = function() self:resumeGame() end },
        { text = "OPTIONS",   action = function() GameState:switch("Options", "Pause") end },
        { text = "SAVE GAME", action = function() self:saveGame() end },
        { text = "QUIT TO MENU", action = function() self:quitToMenu() end }
    }
    self.selectedOption = 1
    self.background     = nil  -- will hold an Image if we can snapshot
end

function PauseState:enter()
    Debug:log("Entered pause state")

    -- Try to snapshot the current backbuffer if supported
    if love.graphics.newScreenshot then
        local data = love.graphics.newScreenshot()          -- ImageData
        self.background = love.graphics.newImage(data)      -- convert to Image
    else
        self.background = nil
    end

    Audio:playSound("pause")
    Audio:pauseMusic()
    self:createUI()
end

function PauseState:createUI()
    UI:clearElements()
    local w,h = love.graphics.getDimensions()

    UI:createPanel((w-300)/2, (h-400)/2, 300, 400)

    UI:createLabel(w/2, (h-400)/2 + 40, "PAUSED", Fonts.large, Constants.COLORS.WHITE, 6)

    for i, opt in ipairs(self.options) do
        UI:createButton(
            w/2 - 100,
            (h-400)/2 + 100 + (i-1)*60,
            200, 50,
            opt.text,
            opt.action,
            6
        )
    end
end

function PauseState:resumeGame()
    Audio:playSound("unpause")
    Audio:resumeMusic()
    GameState:switch("Play")
end

function PauseState:saveGame()
    Audio:playSound("save")
    local ok = SaveLoad:saveGame("quicksave")
    Debug:log(ok and "Game saved successfully" or "Failed to save game")
end

function PauseState:quitToMenu()
    Audio:playSound("menu_back")
    local w,h = love.graphics.getDimensions()
    local panelX, panelY = (w-350)/2, (h-200)/2

    UI:createPanel(panelX, panelY, 350, 200, 7)
    UI:createLabel(w/2, panelY+50, "Quit without saving?", Fonts.medium, Constants.COLORS.WHITE, 7)

    UI:createButton(
        panelX+50, panelY+130, 100, 40,
        "Yes",
        function()
            Audio:stopMusic()
            GameState:switch("Menu")
        end,
        7
    )
    UI:createButton(
        panelX+200, panelY+130, 100, 40,
        "No",
        function()
            UI:clearElements()
            self:createUI()
        end,
        7
    )
end

function PauseState:update(dt)
    -- nothing to animate here
end

function PauseState:draw()
    -- draw the frozen‐in‐time game behind
    if self.background then
        love.graphics.setColor(0.5,0.5,0.5,1)
        love.graphics.draw(self.background, 0, 0)
    end

    -- darken
    love.graphics.setColor(0,0,0,0.7)
    local w,h = love.graphics.getDimensions()
    love.graphics.rectangle("fill", 0,0, w,h)

    love.graphics.setColor(1,1,1,1)
end

function PauseState:keypressed(key)
    if key=="escape" or key=="p" then
        self:resumeGame()
        return true
    end
    -- navigation falls through to UI:keypressed
    return false
end

PauseState:init()
return PauseState