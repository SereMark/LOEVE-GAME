local Label = Class:extend()

function Label:init(x, y, text, font, color)
    self.x = x
    self.y = y
    self.text = text or ""
    self.font = font or Fonts.medium
    self.color = color or Constants.COLORS.WHITE
    
    -- State
    self.visible = true
    self.passThrough = true  -- Let clicks pass through
    
    -- Alignment (center by default)
    self.alignX = "center"
    self.alignY = "center"
    
    -- Calculate dimensions
    self:updateDimensions()
end

function Label:updateDimensions()
    -- Calculate size based on text
    self.width = self.font:getWidth(self.text)
    self.height = self.font:getHeight()
end

function Label:update(dt)
    -- No update logic needed
end

function Label:draw()
    love.graphics.setColor(self.color)
    love.graphics.setFont(self.font)
    
    local x = self.x
    local y = self.y
    
    -- Apply horizontal alignment
    if self.alignX == "center" then
        x = x - self.width / 2
    elseif self.alignX == "right" then
        x = x - self.width
    end
    
    -- Apply vertical alignment
    if self.alignY == "center" then
        y = y - self.height / 2
    elseif self.alignY == "bottom" then
        y = y - self.height
    end
    
    love.graphics.print(self.text, x, y)
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

function Label:contains(x, y)
    -- Calculate position based on alignment
    local labelX = self.x
    local labelY = self.y
    
    if self.alignX == "center" then
        labelX = labelX - self.width / 2
    elseif self.alignX == "right" then
        labelX = labelX - self.width
    end
    
    if self.alignY == "center" then
        labelY = labelY - self.height / 2
    elseif self.alignY == "bottom" then
        labelY = labelY - self.height
    end
    
    return x >= labelX and x <= labelX + self.width and
           y >= labelY and y <= labelY + self.height
end

function Label:setText(text)
    self.text = text
    self:updateDimensions()
end

function Label:setFont(font)
    self.font = font
    self:updateDimensions()
end

function Label:setColor(color)
    self.color = color
end

function Label:setAlignment(x, y)
    self.alignX = x or self.alignX
    self.alignY = y or self.alignY
end

-- Event handlers (return false to let events pass through)
function Label:mousepressed(x, y, button) return false end
function Label:mousereleased(x, y, button) return false end
function Label:mousemoved(x, y, dx, dy) return false end
function Label:keypressed(key) return false end
function Label:keyreleased(key) return false end
function Label:wheelmoved(x, y) return false end

return Label