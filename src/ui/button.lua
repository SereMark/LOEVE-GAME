local Button = Class:extend()

function Button:init(x, y, width, height, text, callback)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.text = text or "Button"
    self.callback = callback
    
    -- State
    self.visible = true
    self.enabled = true
    self.hovered = false
    self.pressed = false
    self.passThrough = false
    
    -- Style
    self.textColor = Constants.COLORS.WHITE
    self.backgroundColor = Constants.COLORS.UI_BG
    self.borderColor = Constants.COLORS.UI_BORDER
    self.hoverColor = Constants.COLORS.UI_HIGHLIGHT
    self.disabledColor = Constants.COLORS.GRAY
    self.borderWidth = Constants.UI.BORDER_WIDTH
    self.font = Fonts.medium
    self.cornerRadius = 5
    self.padding = Constants.UI.PADDING
end

function Button:update(dt)
    -- No specific update logic needed
end

function Button:draw()
    -- Set color based on state
    local bgColor = self.backgroundColor
    
    if not self.enabled then
        bgColor = self.disabledColor
    elseif self.pressed then
        bgColor = self.hoverColor
    elseif self.hovered then
        bgColor = {
            bgColor[1] * 1.2,
            bgColor[2] * 1.2,
            bgColor[3] * 1.2,
            bgColor[4]
        }
    end
    
    -- Draw background
    love.graphics.setColor(bgColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, self.cornerRadius, self.cornerRadius)
    
    -- Draw border
    love.graphics.setColor(self.borderColor)
    love.graphics.setLineWidth(self.borderWidth)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height, self.cornerRadius, self.cornerRadius)
    
    -- Draw text
    love.graphics.setColor(self.textColor)
    love.graphics.setFont(self.font)
    
    local textWidth = self.font:getWidth(self.text)
    local textHeight = self.font:getHeight()
    local textX = self.x + (self.width - textWidth) / 2
    local textY = self.y + (self.height - textHeight) / 2
    
    love.graphics.print(self.text, textX, textY)
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

function Button:contains(x, y)
    return x >= self.x and x <= self.x + self.width and
           y >= self.y and y <= self.y + self.height
end

function Button:onClick()
    if self.enabled and self.callback then
        self.callback()
    end
end

function Button:mousepressed(x, y, button)
    return button == 1 and self.enabled  -- Only handle left clicks
end

function Button:mousereleased(x, y, button)
    return button == 1 and self.enabled
end

function Button:mousemoved(x, y, dx, dy)
    return false
end

function Button:keypressed(key)
    if not self.enabled then return false end
    
    if key == "return" or key == "space" then
        self:onClick()
        return true
    end
    
    return false
end

function Button:keyreleased(key)
    return false
end

function Button:wheelmoved(x, y)
    return false
end

function Button:setText(text)
    self.text = text
end

function Button:setEnabled(enabled)
    self.enabled = enabled
end

function Button:setVisible(visible)
    self.visible = visible
end

return Button