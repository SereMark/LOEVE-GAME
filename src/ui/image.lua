local Image = Class:extend()

function Image:init(x, y, image, scale)
    self.x = x
    self.y = y
    
    -- Image can be a string (image name) or an actual image object
    if type(image) == "string" then
        self.image = Assets:getImage(image)
    else
        self.image = image or Assets:getImage("placeholder")
    end
    
    self.scale = scale or 1
    self.color = {1, 1, 1, 1}
    self.rotation = 0
    
    -- Calculate dimensions
    self.width = self.image:getWidth() * self.scale
    self.height = self.image:getHeight() * self.scale
    
    -- Origin (center by default)
    self.originX = self.width / 2
    self.originY = self.height / 2
    
    -- State
    self.visible = true
    self.passThrough = true  -- Let clicks pass through
    
    -- Callbacks
    self.onClick = nil
end

function Image:update(dt)
    -- No update logic needed
end

function Image:draw()
    love.graphics.setColor(self.color)
    
    love.graphics.draw(
        self.image,
        self.x,
        self.y,
        self.rotation,
        self.scale,
        self.scale,
        self.originX / self.scale,
        self.originY / self.scale
    )
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

function Image:contains(x, y)
    -- Simple rectangular check
    local left = self.x - self.originX
    local top = self.y - self.originY
    
    return x >= left and x <= left + self.width and
           y >= top and y <= top + self.height
end

function Image:setImage(image)
    if type(image) == "string" then
        self.image = Assets:getImage(image)
    else
        self.image = image
    end
    
    -- Update dimensions
    self.width = self.image:getWidth() * self.scale
    self.height = self.image:getHeight() * self.scale
    
    -- Update origin if set to center
    if self.originX == self.width / 2 and self.originY == self.height / 2 then
        self.originX = self.width / 2
        self.originY = self.height / 2
    end
end

function Image:setColor(color)
    self.color = color
end

function Image:setScale(scale)
    self.scale = scale
    
    -- Update dimensions
    self.width = self.image:getWidth() * self.scale
    self.height = self.image:getHeight() * self.scale
    
    -- Update origin if set to center
    if self.originX == self.width / 2 and self.originY == self.height / 2 then
        self.originX = self.width / 2
        self.originY = self.height / 2
    end
end

function Image:setOrigin(x, y)
    self.originX = x or self.width / 2
    self.originY = y or self.height / 2
end

-- Event handlers (pass through by default)
function Image:mousepressed(x, y, button)
    return false
end

function Image:mousereleased(x, y, button)
    if button == 1 and self.onClick and self:contains(x, y) then
        self.onClick()
        return true
    end
    return false
end

function Image:mousemoved(x, y, dx, dy) return false end
function Image:keypressed(key) return false end
function Image:keyreleased(key) return false end
function Image:wheelmoved(x, y) return false end

return Image