local State = require("src.states.state")
local Constants = require("src.constants")
local Player = require("src.entities.player")
local GameState = require("src.states.gamestate")
local Debug = require("src.utils.debug")
local Enemy = require("src.entities.basic_enemy")

local PlayState = State:new("Play")

function PlayState:init()
    self.player = Player:new(400, 300)
    self.paused = false
    self.enemy = Enemy:new(500,500)
end

function PlayState:enter()
    Debug:log("Entered play state")
end

function PlayState:update(dt)
    if self.paused then return end
    
    -- Update player
    self.player:update(dt)
end

function PlayState:draw()
    local width, height = love.graphics.getDimensions()
    
    -- Draw background
    love.graphics.setColor(Constants.COLORS.BACKGROUND)
    love.graphics.rectangle("fill", 0, 0, width, height)
    
    -- Draw player properties
    self.player:draw()
    self.player:vision()

    -- Draw enemy only if it is in the player's vision
    if self.player:isInVision(self.enemy.x + self.enemy.width / 2, self.enemy.y + self.enemy.height / 2) then
        self.enemy:draw()
    end
    
    -- Draw pause indicator
    if self.paused then
        love.graphics.setColor(Constants.COLORS.WHITE)
        love.graphics.setFont(Fonts.large)
        local pauseText = "PAUSED"
        local textWidth = Fonts.large:getWidth(pauseText)
        love.graphics.print(pauseText, width / 2 - textWidth / 2, height / 2 - Fonts.large:getHeight() / 2)
    end
    
    -- Reset color
    love.graphics.setColor(Constants.COLORS.WHITE)
end

function PlayState:keypressed(key)
    if key == "escape" then
        self.paused = not self.paused
    elseif key == "m" then
        GameState:switch("Menu")
    end
    
    -- Pass input to player if not paused
    if not self.paused then
        self.player:keypressed(key)
    end
end

PlayState:init()

return PlayState