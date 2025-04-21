local State = require("src.states.state")
local Constants = require("src.constants")
local GameState = require("src.states.gamestate")
local Debug = require("src.utils.debug")

local MenuState = State:new("Menu")

function MenuState:init()
    self.title = Constants.GAME.TITLE
    self.options = {
        {text = "START GAME", action = function() GameState:switch("Play") end},
        {text = "OPTIONS", action = function() GameState:switch("Options", "Menu") end},
        {text = "QUIT", action = function() love.event.quit() end}
    }
    self.selectedOption = 1
    self.backgroundStars = {}
    
    -- Generate random stars for background
    for i = 1, 100 do
        table.insert(self.backgroundStars, {
            x = love.math.random(0, love.graphics.getWidth()),
            y = love.math.random(0, love.graphics.getHeight()),
            size = love.math.random(1, 3),
            alpha = love.math.random(50, 255) / 255,
            speed = love.math.random(10, 30)
        })
    end
    
    -- Create UI elements
    self:createUI()
end

function MenuState:createUI()
    -- Clear previous UI
    UI:clearElements()
    
    local width, height = love.graphics.getDimensions()
    
    -- Create title
    UI:createLabel(
        width / 2,
        height / 4,
        self.title,
        Fonts.title,
        Constants.COLORS.WHITE
    )
    
    -- Create menu buttons
    for i, option in ipairs(self.options) do
        UI:createButton(
            width / 2 - 150,
            height / 2 + (i-1) * 70,
            300,
            60,
            option.text,
            option.action
        )
    end
    
    -- Add a version label
    UI:createLabel(
        width - 10,
        height - 10,
        "v" .. Constants.GAME.VERSION,
        Fonts.small,
        Constants.COLORS.GRAY
    ):setAlignment("right", "bottom")
end

function MenuState:enter()
    Debug:log("Entered menu state")
    
    -- Play menu music
    Audio:playMusic("menu", 0.7, true)
    
    -- Create UI elements
    self:createUI()
end

function MenuState:update(dt)
    -- Update background stars
    for _, star in ipairs(self.backgroundStars) do
        star.y = star.y + star.speed * dt
        if star.y > love.graphics.getHeight() then
            star.y = 0
            star.x = love.math.random(0, love.graphics.getWidth())
        end
    end
end

function MenuState:draw()
    local width, height = love.graphics.getDimensions()
    
    -- Draw background
    love.graphics.setColor(Constants.COLORS.BACKGROUND)
    love.graphics.rectangle("fill", 0, 0, width, height)
    
    -- Draw stars
    for _, star in ipairs(self.backgroundStars) do
        love.graphics.setColor(1, 1, 1, star.alpha)
        love.graphics.circle("fill", star.x, star.y, star.size)
    end
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

function MenuState:keypressed(key)
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
end

function MenuState:resize(w, h)
    -- Recreate UI for new dimensions
    self:createUI()
end

MenuState:init()

return MenuState