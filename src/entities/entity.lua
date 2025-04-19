local Class = require("libs.class")
local Constants = require("src.constants")
local Helpers = require("src.utils.helpers")

local Entity = Class:extend()

function Entity:init(x, y, width, height)
    self.x = x or 0
    self.y = y or 0
    self.width = width or 32
    self.height = height or 32
    self.velocity = {x = 0, y = 0}
    self.color = Constants.COLORS.WHITE
end

function Entity:update(dt)
    -- Apply velocity
    self.x = self.x + self.velocity.x * dt
    self.y = self.y + self.velocity.y * dt
    
    -- Keep in bounds
    local width, height = love.graphics.getDimensions()
    self.x = Helpers.clamp(self.x, 0, width - self.width)
    self.y = Helpers.clamp(self.y, 0, height - self.height)
end

function Entity:draw()
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

function Entity:collidesWith(other)
    return self.x < other.x + other.width and
           self.x + self.width > other.x and
           self.y < other.y + other.height and
           self.y + self.height > other.y
end

return Entity