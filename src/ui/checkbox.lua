local Checkbox = Class:extend()

function Checkbox:init(x, y, size, checked, callback)
    self.x = x
    self.y = y
    self.size = size or 20
    self.checked = checked or false
    self.callback = callback
    
    -- State
    self.visible = true
    self.enabled = true
    self.hovered = false
    self.pressed = false
    self.passThrough = false
    
    -- Style
    self.borderColor = Constants.COLORS.UI_BORDER
    self.fillColor = Constants.COLORS.UI_HIGHLIGHT
    self.backgroundColor = Constants.COLORS.UI_BG
    self.checkColor = Constants.COLORS.WHITE
    self.disabledColor = Constants.COLORS.GRAY
    self.borderWidth = Constants.UI.BORDER_WIDTH
    self.cornerRadius = 3
end

function Checkbox:update(dt)
    -- No update logic needed
end

function Checkbox:draw()
    -- Draw background
    if self.enabled then
        love.graphics.setColor(self.backgroundColor)
    else
        love.graphics.setColor(self.disabledColor)
    end
    
    love.graphics.rectangle("fill", self.x, self.y, self.size, self.size, self.cornerRadius, self.cornerRadius)
    
    -- Draw border
    love.graphics.setColor(self.borderColor)
    love.graphics.setLineWidth(self.borderWidth)
    love.graphics.rectangle("line", self.x, self.y, self.size, self.size, self.cornerRadius, self.cornerRadius)
    
    -- Draw check mark if checked
    if self.checked then
        love.graphics.setColor(self.checkColor)
        
        -- Draw a check mark
        local padding = self.size * 0.2
        local x1 = self.x + padding
        local y1 = self.y + self.size / 2
        local x2 = self.x + self.size * 0.4
        local y2 = self.y + self.size - padding
        local x3 = self.x + self.size - padding
        local y3 = self.y + padding
        
        love.graphics.setLineWidth(self.size * 0.15)
        love.graphics.line(x1, y1, x2, y2, x3, y3)
    end
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

function Checkbox:contains(x, y)
    return x >= self.x and x <= self.x + self.size and
           y >= self.y and y <= self.y + self.size
end

function Checkbox:toggle()
    if not self.enabled then return end
    
    self.checked = not self.checked
    
    if self.callback then
        self.callback(self.checked)
    end
end

function Checkbox:setChecked(checked)
    self.checked = checked
    
    if self.callback then
        self.callback(self.checked)
    end
end

function Checkbox:isChecked()
    return self.checked
end

function Checkbox:mousepressed(x, y, button)
    return self.enabled and button == 1
end

function Checkbox:mousereleased(x, y, button)
    if not self.enabled or button ~= 1 then return false end
    
    if self.pressed and self:contains(x, y) then
        self:toggle()
        return true
    end
    
    return false
end

function Checkbox:mousemoved(x, y, dx, dy)
    return false
end

function Checkbox:keypressed(key)
    if not self.enabled then return false end
    
    if key == "return" or key == "space" then
        self:toggle()
        return true
    end
    
    return false
end

function Checkbox:keyreleased(key)
    return false
end

function Checkbox:wheelmoved(x, y)
    return false
end

function Checkbox:setEnabled(enabled)
    self.enabled = enabled
end

return Checkbox