local Entity = require("src.entities.entity")
local Constants = require("src.constants")
local Helpers = require("src.utils.helpers")
local Debug = require("src.utils.debug")

local Player = Entity:extend()

function Player:init(x, y)
    Player.super.init(self, x, y, Constants.PLAYER.SIZE, Constants.PLAYER.SIZE)
    self.speed = Constants.PLAYER.SPEED
    self.color = Constants.COLORS.GREEN
end

function Player:update(dt)
    -- Reset velocity
    self.velocity.x = 0
    self.velocity.y = 0
    
    -- Handle keyboard input
    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        self.velocity.x = -self.speed
    elseif love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        self.velocity.x = self.speed
    end
    
    if love.keyboard.isDown("up") or love.keyboard.isDown("w") then
        self.velocity.y = -self.speed
    elseif love.keyboard.isDown("down") or love.keyboard.isDown("s") then
        self.velocity.y = self.speed
    end
    
    -- Call parent update method
    Player.super.update(self, dt)
end

function Player:draw()
    -- Draw a more complex player shape (a triangle)
    love.graphics.setColor(self.color)
    love.graphics.polygon("fill", 
        self.x + self.width/2, self.y,                       -- top
        self.x, self.y + self.height,                        -- bottom left
        self.x + self.width, self.y + self.height            -- bottom right
    )
    
    -- Reset color
    love.graphics.setColor(Constants.COLORS.WHITE)
end

function Player:keypressed(key)
    if key == "space" then
        -- Example of an action when spacebar is pressed
        self.color = Helpers.randomColor()
        Debug:log("Player changed color")
    end
end

return Player