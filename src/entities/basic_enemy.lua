local Entity = require("src.entities.entity")
local Constants = require("src.constants")
local Helpers = require("src.utils.helpers")
local Debug = require("src.utils.debug")

local Enemy = Entity:extend()

function Enemy:init(x, y)
    Enemy.super.init(self, x, y, Constants.ENEMY.BASIC.SIZE, Constants.ENEMY.BASIC.SIZE)
    self.color = Constants.COLORS.ENEMY
end

function Enemy:draw()
    -- Draw a more complex Enemy shape (a triangle)
    love.graphics.setColor(self.color)
    love.graphics.polygon("fill", 
        self.x + self.width/2, self.y,                       -- top
        self.x, self.y + self.height,                        -- bottom left
        self.x + self.width, self.y + self.height            -- bottom right
    )
    -- Reset color
    love.graphics.setColor(Constants.COLORS.WHITE)
end

return Enemy