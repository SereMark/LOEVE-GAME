local ProgressBar = Class:extend()

function ProgressBar:init(x, y, width, height, value, maxValue, color)
    self.x = x
    self.y = y
    self.width = width
    self.height = height or 20
    
    self.value = value or 0
    self.maxValue = maxValue or 100
    self.percentage = self.value / self.maxValue
    
    -- State
    self.visible = true
    self.passThrough = true  -- Let clicks pass through
    
    -- Style
    self.backgroundColor = Constants.COLORS.UI_BG
    self.borderColor = Constants.COLORS.UI_BORDER
    self.fillColor = color or Constants.COLORS.UI_HIGHLIGHT
    self.textColor = Constants.COLORS.WHITE
    self.borderWidth = Constants.UI.BORDER_WIDTH
    self.cornerRadius = 5
    
    -- Display options
    self.showText = true
    self.showBorder = true
    self.text = nil  -- Custom text, if nil will show percentage
    self.font = Fonts.small
end

function ProgressBar:update(dt)
    -- No update logic needed
end

function ProgressBar:draw()
    -- Draw background
    love.graphics.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, self.cornerRadius, self.cornerRadius)
    
    -- Draw filled portion
    local fillWidth = self.width * self.percentage
    
    if fillWidth > 0 then
        love.graphics.setColor(self.fillColor)
        
        -- If fillWidth is less than corner radius * 2, draw without rounded corners on right
        if fillWidth < self.cornerRadius * 2 then
            love.graphics.rectangle("fill", self.x, self.y, fillWidth, self.height, self.cornerRadius, self.cornerRadius, 0, 0)
        else
            love.graphics.rectangle("fill", self.x, self.y, fillWidth, self.height, self.cornerRadius, self.cornerRadius)
        end
    end
    
    -- Draw border
    if self.showBorder then
        love.graphics.setColor(self.borderColor)
        love.graphics.setLineWidth(self.borderWidth)
        love.graphics.rectangle("line", self.x, self.y, self.width, self.height, self.cornerRadius, self.cornerRadius)
    end
    
    -- Draw text
    if self.showText then
        love.graphics.setColor(self.textColor)
        love.graphics.setFont(self.font)
        
        local text = self.text
        if not text then
            text = math.floor(self.percentage * 100) .. "%"
        end
        
        local textWidth = self.font:getWidth(text)
        local textHeight = self.font:getHeight()
        local textX = self.x + (self.width - textWidth) / 2
        local textY = self.y + (self.height - textHeight) / 2
        
        love.graphics.print(text, textX, textY)
    end
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

function ProgressBar:contains(x, y)
    return x >= self.x and x <= self.x + self.width and
           y >= self.y and y <= self.y + self.height
end

function ProgressBar:setValue(value)
    self.value = Helpers.clamp(value, 0, self.maxValue)
    self.percentage = self.value / self.maxValue
end

function ProgressBar:setMaxValue(maxValue)
    self.maxValue = maxValue
    self:setValue(self.value)  -- Recalculate percentage
end

function ProgressBar:setPercentage(percentage)
    self.percentage = Helpers.clamp(percentage, 0, 1)
    self.value = self.percentage * self.maxValue
end

function ProgressBar:getText()
    return self.text
end

function ProgressBar:setText(text)
    self.text = text
end

function ProgressBar:setShowText(show)
    self.showText = show
end

function ProgressBar:setShowBorder(show)
    self.showBorder = show
end

function ProgressBar:setColor(color)
    self.fillColor = color
end

-- Event handlers (all pass through)
function ProgressBar:mousepressed(x, y, button) return false end
function ProgressBar:mousereleased(x, y, button) return false end
function ProgressBar:mousemoved(x, y, dx, dy) return false end
function ProgressBar:keypressed(key) return false end
function ProgressBar:keyreleased(key) return false end
function ProgressBar:wheelmoved(x, y) return false end

return ProgressBar