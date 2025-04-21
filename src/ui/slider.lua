local Slider = Class:extend()

function Slider:init(x, y, width, height, min, max, value, callback)
    self.x = x
    self.y = y
    self.width = width
    self.height = height or 20
    
    -- Value range
    self.min = min or 0
    self.max = max or 100
    self.value = Helpers.clamp(value or self.min, self.min, self.max)
    
    -- Handle size
    self.handleWidth = height or 20
    self.handleHeight = height or 20
    
    -- Callback
    self.callback = callback
    
    -- State
    self.visible = true
    self.enabled = true
    self.hovered = false
    self.pressed = false
    self.passThrough = false
    
    -- Style
    self.backgroundColor = Constants.COLORS.UI_BG
    self.borderColor = Constants.COLORS.UI_BORDER
    self.handleColor = Constants.COLORS.UI_HIGHLIGHT
    self.barColor = {0.2, 0.2, 0.2, 1}
    self.disabledColor = Constants.COLORS.GRAY
    self.borderWidth = Constants.UI.BORDER_WIDTH
    self.cornerRadius = 5
    
    -- Calculate handle position
    self:updateHandlePosition()
end

function Slider:updateHandlePosition()
    local range = self.max - self.min
    local normalizedValue = (self.value - self.min) / range
    
    self.handleX = self.x + normalizedValue * (self.width - self.handleWidth)
end

function Slider:update(dt)
    -- No update logic needed
end

function Slider:draw()
    -- Draw background bar
    love.graphics.setColor(self.barColor)
    love.graphics.rectangle("fill", self.x, self.y + (self.height - 8) / 2, self.width, 8, 4, 4)
    
    -- Draw filled portion
    local fillWidth = self.handleX - self.x + self.handleWidth / 2
    love.graphics.setColor(self.handleColor)
    love.graphics.rectangle("fill", self.x, self.y + (self.height - 8) / 2, fillWidth, 8, 4, 4)
    
    -- Draw handle
    if self.enabled then
        if self.pressed then
            love.graphics.setColor(self.handleColor[1] * 0.8, self.handleColor[2] * 0.8, self.handleColor[3] * 0.8, self.handleColor[4])
        elseif self.hovered then
            love.graphics.setColor(self.handleColor[1] * 1.2, self.handleColor[2] * 1.2, self.handleColor[3] * 1.2, self.handleColor[4])
        else
            love.graphics.setColor(self.handleColor)
        end
    else
        love.graphics.setColor(self.disabledColor)
    end
    
    love.graphics.rectangle("fill", self.handleX, self.y, self.handleWidth, self.handleHeight, self.cornerRadius, self.cornerRadius)
    
    -- Draw handle border
    love.graphics.setColor(self.borderColor)
    love.graphics.setLineWidth(self.borderWidth)
    love.graphics.rectangle("line", self.handleX, self.y, self.handleWidth, self.handleHeight, self.cornerRadius, self.cornerRadius)
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

function Slider:contains(x, y)
    return x >= self.x and x <= self.x + self.width and
           y >= self.y and y <= self.y + self.height
end

function Slider:containsHandle(x, y)
    return x >= self.handleX and x <= self.handleX + self.handleWidth and
           y >= self.y and y <= self.y + self.handleHeight
end

function Slider:setValue(value)
    self.value = Helpers.clamp(value, self.min, self.max)
    self:updateHandlePosition()
    
    if self.callback then
        self.callback(self.value)
    end
end

function Slider:setValueFromPosition(x)
    -- Convert x position to slider value
    local relativeX = Helpers.clamp(x - self.x, 0, self.width)
    local normalizedValue = relativeX / self.width
    local value = self.min + normalizedValue * (self.max - self.min)
    
    self:setValue(value)
end

function Slider:mousepressed(x, y, button)
    if not self.enabled or button ~= 1 then return false end
    
    if self:containsHandle(x, y) then
        self.pressed = true
        self.dragOffsetX = x - self.handleX
        return true
    elseif self:contains(x, y) then
        -- Click on the bar, move handle to that position
        self.pressed = true
        self.dragOffsetX = self.handleWidth / 2
        self:setValueFromPosition(x - self.dragOffsetX)
        return true
    end
    
    return false
end

function Slider:mousereleased(x, y, button)
    if not self.enabled or button ~= 1 then return false end
    
    if self.pressed then
        self.pressed = false
        return true
    end
    
    return false
end

function Slider:mousemoved(x, y, dx, dy)
    if not self.enabled then return false end
    
    if self.pressed then
        -- Update handle position based on drag
        self:setValueFromPosition(x - self.dragOffsetX)
        return true
    end
    
    return false
end

function Slider:keypressed(key)
    if not self.enabled then return false end
    
    local step = (self.max - self.min) / 20  -- 5% increments
    
    if key == "left" or key == "down" then
        self:setValue(self.value - step)
        return true
    elseif key == "right" or key == "up" then
        self:setValue(self.value + step)
        return true
    end
    
    return false
end

function Slider:keyreleased(key)
    return false
end

function Slider:wheelmoved(x, y)
    if not self.enabled then return false end
    
    if self.hovered then
        local step = (self.max - self.min) / 20  -- 5% increments
        self:setValue(self.value + y * step)
        return true
    end
    
    return false
end

function Slider:setEnabled(enabled)
    self.enabled = enabled
end

return Slider