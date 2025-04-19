local State = require("src.states.state")
local Constants = require("src.constants")
local GameState = require("src.states.gamestate")
local Debug = require("src.utils.debug")

local MenuState = State:new("Menu")

function MenuState:init()
    self.title = "LÖVE STARTER"
    self.options = {
        {text = "START GAME", action = function() GameState:switch("Play") end},
        {text = "OPTIONS", action = function() Debug:log("Options not implemented") end},
        {text = "QUIT", action = function() love.event.quit() end}
    }
    self.selectedOption = 1
end

function MenuState:update(dt)
    -- Add any menu animations or logic here
end

function MenuState:draw()
    local width, height = love.graphics.getDimensions()
    
    -- Draw background
    love.graphics.setColor(Constants.COLORS.BACKGROUND)
    love.graphics.rectangle("fill", 0, 0, width, height)
    
    -- Draw title
    love.graphics.setColor(Constants.COLORS.WHITE)
    love.graphics.setFont(Fonts.large)
    local titleWidth = Fonts.large:getWidth(self.title)
    love.graphics.print(self.title, width/2 - titleWidth/2, height/4)
    
    -- Draw menu options
    love.graphics.setFont(Fonts.medium)
    for i, option in ipairs(self.options) do
        if i == self.selectedOption then
            love.graphics.setColor(Constants.COLORS.GREEN)
        else
            love.graphics.setColor(Constants.COLORS.WHITE)
        end
        
        local optionWidth = Fonts.medium:getWidth(option.text)
        love.graphics.print(option.text, width/2 - optionWidth/2, height/2 + (i-1) * 50)
    end
    
    -- Reset color
    love.graphics.setColor(Constants.COLORS.WHITE)
end

function MenuState:keypressed(key)
    if key == "up" then
        self.selectedOption = self.selectedOption - 1
        if self.selectedOption < 1 then
            self.selectedOption = #self.options
        end
    elseif key == "down" then
        self.selectedOption = self.selectedOption + 1
        if self.selectedOption > #self.options then
            self.selectedOption = 1
        end
    elseif key == "return" or key == "space" then
        self.options[self.selectedOption].action()
    end
end

MenuState:init()

return MenuState