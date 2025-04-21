local State = require("src.states.state")
local Constants = require("src.constants")
local GameState = require("src.states.gamestate")
local Debug = require("src.utils.debug")

local OptionsState = State:new("Options")

function OptionsState:init()
    self.previousState = "Menu"
    self.options = {
        {name = "Music Volume", value = Audio.musicVolume * 100, min = 0, max = 100, step = 5},
        {name = "SFX Volume", value = Audio.sfxVolume * 100, min = 0, max = 100, step = 5},
        {name = "Fullscreen", value = love.window.getFullscreen() and "On" or "Off", toggle = true},
        {name = "VSync", value = love.window.getVSync() and "On" or "Off", toggle = true},
        {name = "Show FPS", value = Constants.GAME.DEBUG and "On" or "Off", toggle = true}
    }
    self.selectedOption = 1
    self.uiElements = {}
end

function OptionsState:enter(previous)
    Debug:log("Entered options state")
    self.previousState = previous or "Menu"
    
    -- Play menu sound
    Audio:playSound("menu_open")
    
    -- Create UI elements
    self:createUI()
end

function OptionsState:createUI()
    -- Clear previous UI
    UI:clearElements()
    
    -- Create panel
    local width, height = love.graphics.getDimensions()
    local panelWidth = width * 0.6
    local panelHeight = height * 0.7
    local panelX = (width - panelWidth) / 2
    local panelY = (height - panelHeight) / 2
    
    local panel = UI:createPanel(panelX, panelY, panelWidth, panelHeight)
    
    -- Create title
    UI:createLabel(width / 2, panelY + 40, "OPTIONS", Fonts.large, Constants.COLORS.WHITE, 6)
    
    -- Create option sliders/toggles
    local startY = panelY + 100
    local optionHeight = 50
    local sliderWidth = panelWidth * 0.6
    
    self.uiElements = {}
    
    for i, option in ipairs(self.options) do
        -- Create label
        UI:createLabel(panelX + 30, startY + (i-1) * optionHeight, option.name, Fonts.medium, Constants.COLORS.WHITE, 6)
        
        if option.toggle then
            -- Create toggle button
            local button = UI:createButton(
                panelX + panelWidth - 150,
                startY + (i-1) * optionHeight - 15,
                100,
                40,
                option.value,
                function() self:toggleOption(i) end,
                6
            )
            self.uiElements[i] = button
        else
            -- Create slider
            local slider = UI:createSlider(
                panelX + panelWidth - sliderWidth - 30,
                startY + (i-1) * optionHeight,
                sliderWidth,
                20,
                option.min,
                option.max,
                option.value,
                function(value) self:updateOption(i, value) end,
                6
            )
            self.uiElements[i] = slider
        end
    end
    
    -- Create back button
    UI:createButton(
        width / 2 - 100,
        panelY + panelHeight - 60,
        200,
        40,
        "Back",
        function() self:backToMenu() end,
        6
    )
end

function OptionsState:updateOption(index, value)
    local option = self.options[index]
    option.value = value
    
    -- Apply option change
    if index == 1 then
        -- Music volume
        Audio:setMusicVolume(value / 100)
    elseif index == 2 then
        -- SFX volume
        Audio:setSFXVolume(value / 100)
        -- Play test sound
        Audio:playSound("menu_click")
    end
    
    -- Save settings
    SaveLoad:saveSettings()
end

function OptionsState:toggleOption(index)
    local option = self.options[index]
    
    -- Toggle value
    if option.value == "On" then
        option.value = "Off"
    else
        option.value = "On"
    end
    
    -- Update UI button text
    if self.uiElements[index] then
        self.uiElements[index]:setText(option.value)
    end
    
    -- Apply option change
    local enabled = (option.value == "On")
    
    if index == 3 then
        -- Fullscreen
        love.window.setFullscreen(enabled)
    elseif index == 4 then
        -- VSync
        love.window.setVSync(enabled and 1 or 0)
    elseif index == 5 then
        -- Show FPS
        Constants.GAME.DEBUG = enabled
    end
    
    -- Play toggle sound
    Audio:playSound("menu_click")
    
    -- Save settings
    SaveLoad:saveSettings()
end

function OptionsState:backToMenu()
    -- Play sound
    Audio:playSound("menu_back")
    
    -- Return to previous state
    GameState:switch(self.previousState)
end

function OptionsState:update(dt)
    -- No additional update logic needed
end

function OptionsState:draw()
    local width, height = love.graphics.getDimensions()
    
    -- Draw background
    love.graphics.setColor(Constants.COLORS.BACKGROUND)
    love.graphics.rectangle("fill", 0, 0, width, height)
end

function OptionsState:keypressed(key)
    if key == "escape" then
        self:backToMenu()
        return true
    end
    
    -- Navigate using arrow keys
    if key == "up" then
        self.selectedOption = math.max(1, self.selectedOption - 1)
        Audio:playSound("menu_move")
    elseif key == "down" then
        self.selectedOption = math.min(#self.options, self.selectedOption + 1)
        Audio:playSound("menu_move")
    elseif key == "left" then
        local option = self.options[self.selectedOption]
        if option.toggle then
            self:toggleOption(self.selectedOption)
        else
            local newValue = math.max(option.min, option.value - option.step)
            self:updateOption(self.selectedOption, newValue)
            if self.uiElements[self.selectedOption] then
                self.uiElements[self.selectedOption].value = newValue
            end
        end
    elseif key == "right" then
        local option = self.options[self.selectedOption]
        if option.toggle then
            self:toggleOption(self.selectedOption)
        else
            local newValue = math.min(option.max, option.value + option.step)
            self:updateOption(self.selectedOption, newValue)
            if self.uiElements[self.selectedOption] then
                self.uiElements[self.selectedOption].value = newValue
            end
        end
    elseif key == "return" or key == "space" then
        local option = self.options[self.selectedOption]
        if option.toggle then
            self:toggleOption(self.selectedOption)
        end
    end
    
    return false
end

OptionsState:init()

return OptionsState