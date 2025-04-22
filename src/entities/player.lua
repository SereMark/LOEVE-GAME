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
        self.x + self.width/2, self.y,                       -- top left
        self.x, self.y + self.height,                        -- bottom left
        self.x + self.width, self.y + self.height            -- bottom right
    )
    
    -- Reset color
    love.graphics.setColor(Constants.COLORS.WHITE)
end
function Player:vision()
    self:ConeParemeters()

    -- Draw the vision cone with 80% transparency
    love.graphics.setColor(Constants.COLORS.YELLOW[1], Constants.COLORS.YELLOW[2], Constants.COLORS.YELLOW[3], 0.2)

    -- Calculate the player's center
    local centerX = self.x + self.width / 2
    local centerY = self.y + self.height / 2

    -- Define the radius of the vision cone
    local radius = 125 -- Vision cone length

    -- Calculate points along the arc
    local segments = 20 -- Number of segments for the arc
    local vertices = {centerX, centerY} -- Start with the player's center
    local angleLeft = math.atan2(self.coneLeftY - centerY, self.coneLeftX - centerX)
    local angleRight = math.atan2(self.coneRightY - centerY, self.coneRightX - centerX)

    -- Normalize angles to [0, 2π]
    if angleLeft < 0 then
        angleLeft = angleLeft + 2 * math.pi
    end
    if angleRight < 0 then
        angleRight = angleRight + 2 * math.pi
    end

    -- Handle cases where the cone spans across the 0-degree boundary
    if angleRight < angleLeft then
        angleRight = angleRight + 2 * math.pi
    end

    -- Generate points along the arc
    for i = 0, segments do
        local t = i / segments
        local angle = angleLeft + t * (angleRight - angleLeft)
        local arcX = centerX + math.cos(angle) * radius
        local arcY = centerY + math.sin(angle) * radius
        table.insert(vertices, arcX)
        table.insert(vertices, arcY)
    end

    -- Add the right edge of the cone
    table.insert(vertices, self.coneRightX)
    table.insert(vertices, self.coneRightY)

    -- Draw the cone as a single polygon
    love.graphics.polygon("fill", vertices)

    -- Reset color
    love.graphics.setColor(Constants.COLORS.WHITE)
end

function Player:isInVision(x, y)
    self:ConeParemeters()
    -- Define the vision cone vertices (now a quadrilateral)
    local coneCenter = {self.x + self.width / 2, self.y + self.height / 2} -- Player center
    local coneTop = {self.coneTopX, self.coneTopY}
    local coneLeft = {self.coneLeftX, self.coneLeftY}
    local coneRight = {self.coneRightX, self.coneRightY}

    -- Check if a point is inside a triangle
    local function isPointInTriangle(px, py, ax, ay, bx, by, cx, cy)
        local areaOrig = math.abs((bx - ax) * (cy - ay) - (cx - ax) * (by - ay))
        local area1 = math.abs((ax - px) * (by - py) - (bx - px) * (ay - py))
        local area2 = math.abs((bx - px) * (cy - py) - (cx - px) * (by - py))
        local area3 = math.abs((cx - px) * (ay - py) - (ax - px) * (cy - py))
        return math.abs(areaOrig - (area1 + area2 + area3)) < 0.01
    end

    -- Check if the point is inside either of the two triangles forming the quadrilateral
    return isPointInTriangle(x, y, coneCenter[1], coneCenter[2], coneLeft[1], coneLeft[2], coneTop[1], coneTop[2]) or
           isPointInTriangle(x, y, coneCenter[1], coneCenter[2], coneTop[1], coneTop[2], coneRight[1], coneRight[2])
end


function Player:ConeParemeters()
    -- Get the cursor position
    local mouseX, mouseY = love.mouse.getPosition()

    -- Calculate the angle between the player and the cursor
    local angle = math.atan2(mouseY - (self.y + self.height / 2), mouseX - (self.x + self.width / 2))

    -- Define the length of the vision cone
    local visionLength = 125

    -- Calculate the rotated vision cone vertices
    self.coneTopX = self.x + self.width / 2 + math.cos(angle) * visionLength
    self.coneTopY = self.y + self.height / 2 + math.sin(angle) * visionLength
    self.coneLeftX = self.x + self.width / 2 + math.cos(angle - math.rad(30)) * visionLength
    self.coneLeftY = self.y + self.height / 2 + math.sin(angle - math.rad(30)) * visionLength
    self.coneRightX = self.x + self.width / 2 + math.cos(angle + math.rad(30)) * visionLength
    self.coneRightY = self.y + self.height / 2 + math.sin(angle + math.rad(30)) * visionLength
end

function Player:keypressed(key)
    if key == "space" then
        -- Example of an action when spacebar is pressed
        self.color = Helpers.randomColor()
        Debug:log("Player changed color")
    end
end

return Player