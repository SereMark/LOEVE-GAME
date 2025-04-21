local TextInput = Class:extend()

function TextInput:init(x, y, width, height, text, placeholder, callback)
    self.x = x
    self.y = y
    self.width = width
    self.height = height or 30
    self.text = text or ""
    self.placeholder = placeholder or "Enter text..."
    self.callback = callback
    
    -- State
    self.visible = true
    self.enabled = true
    self.hovered = false
    self.pressed = false
    self.focused = false
    self.passThrough = false
    
    -- Text properties
    self.font = Fonts.medium
    self.cursorPosition = #self.text
    self.cursorVisible = true
    self.cursorBlinkTime = 0
    self.cursorBlinkRate = 0.5
    self.textOffset = 0
    self.selectStart = nil
    self.selectEnd = nil
    
    -- Style
    self.backgroundColor = Constants.COLORS.UI_BG
    self.borderColor = Constants.COLORS.UI_BORDER
    self.textColor = Constants.COLORS.WHITE
    self.placeholderColor = Constants.COLORS.GRAY
    self.focusColor = Constants.COLORS.UI_HIGHLIGHT
    self.disabledColor = Constants.COLORS.GRAY
    self.selectionColor = {0.2, 0.4, 0.8, 0.5}
    self.borderWidth = Constants.UI.BORDER_WIDTH
    self.cornerRadius = 5
    self.padding = 5
end

function TextInput:update(dt)
    -- Update cursor blink
    if self.focused then
        self.cursorBlinkTime = self.cursorBlinkTime + dt
        if self.cursorBlinkTime >= self.cursorBlinkRate then
            self.cursorBlinkTime = self.cursorBlinkTime - self.cursorBlinkRate
            self.cursorVisible = not self.cursorVisible
        end
    else
        self.cursorVisible = false
    end
    
    -- Make sure cursor is in visible area
    self:adjustTextOffset()
end

function TextInput:draw()
    -- Draw background
    if not self.enabled then
        love.graphics.setColor(self.disabledColor)
    elseif self.focused then
        love.graphics.setColor(self.backgroundColor[1] * 1.2, self.backgroundColor[2] * 1.2, self.backgroundColor[3] * 1.2, self.backgroundColor[4])
    else
        love.graphics.setColor(self.backgroundColor)
    end
    
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, self.cornerRadius, self.cornerRadius)
    
    -- Draw border
    if self.focused then
        love.graphics.setColor(self.focusColor)
    else
        love.graphics.setColor(self.borderColor)
    end
    
    love.graphics.setLineWidth(self.borderWidth)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height, self.cornerRadius, self.cornerRadius)
    
    -- Set clipping region to prevent text from overflowing
    love.graphics.setScissor(self.x + self.padding, self.y, self.width - 2 * self.padding, self.height)
    
    -- Draw text
    love.graphics.setFont(self.font)
    
    if #self.text > 0 then
        -- Draw actual text
        love.graphics.setColor(self.textColor)
        love.graphics.print(self.text, self.x + self.padding - self.textOffset, self.y + (self.height - self.font:getHeight()) / 2)
        
        -- Draw selection if any
        if self.focused and self.selectStart and self.selectEnd and self.selectStart ~= self.selectEnd then
            local startPos = math.min(self.selectStart, self.selectEnd)
            local endPos = math.max(self.selectStart, self.selectEnd)
            
            local startX = self.x + self.padding + self.font:getWidth(self.text:sub(1, startPos)) - self.textOffset
            local width = self.font:getWidth(self.text:sub(startPos + 1, endPos))
            
            love.graphics.setColor(self.selectionColor)
            love.graphics.rectangle("fill", startX, self.y + 2, width, self.height - 4)
        end
    else
        -- Draw placeholder
        love.graphics.setColor(self.placeholderColor)
        love.graphics.print(self.placeholder, self.x + self.padding, self.y + (self.height - self.font:getHeight()) / 2)
    end
    
    -- Draw cursor
    if self.focused and self.cursorVisible then
        local cursorX = self.x + self.padding + self.font:getWidth(self.text:sub(1, self.cursorPosition)) - self.textOffset
        
        love.graphics.setColor(self.textColor)
        love.graphics.setLineWidth(1)
        love.graphics.line(cursorX, self.y + 5, cursorX, self.y + self.height - 5)
    end
    
    -- Reset scissor and color
    love.graphics.setScissor()
    love.graphics.setColor(1, 1, 1, 1)
end

function TextInput:contains(x, y)
    return x >= self.x and x <= self.x + self.width and
           y >= self.y and y <= self.y + self.height
end

function TextInput:setText(text)
    self.text = text or ""
    self.cursorPosition = #self.text
    self.selectStart = nil
    self.selectEnd = nil
    
    if self.callback then
        self.callback(self.text)
    end
end

function TextInput:focus()
    self.focused = true
    self.cursorVisible = true
    self.cursorBlinkTime = 0
    
    -- Start text input mode
    love.keyboard.setTextInput(true)
end

function TextInput:blur()
    self.focused = false
    self.selectStart = nil
    self.selectEnd = nil
    
    -- End text input mode if no other text input has focus
    -- TODO: Check if other text inputs exist and have focus before calling setTextInput(false)
    -- love.keyboard.setTextInput(false)
end

function TextInput:adjustTextOffset()
    if not self.focused then return end
    
    -- Calculate cursor position in pixels
    local cursorX = self.font:getWidth(self.text:sub(1, self.cursorPosition))
    
    -- Adjust offset to make cursor visible
    local visibleWidth = self.width - 2 * self.padding
    
    if cursorX - self.textOffset > visibleWidth then
        -- Cursor is too far right
        self.textOffset = cursorX - visibleWidth + 10
    elseif cursorX - self.textOffset < 0 then
        -- Cursor is too far left
        self.textOffset = cursorX - 10
    end
    
    -- Keep offset within valid range
    self.textOffset = math.max(0, self.textOffset)
end

function TextInput:insertText(text)
    if not self.focused or not self.enabled then return end
    
    -- Replace selected text if any
    if self.selectStart and self.selectEnd and self.selectStart ~= self.selectEnd then
        local startPos = math.min(self.selectStart, self.selectEnd)
        local endPos = math.max(self.selectStart, self.selectEnd)
        
        self.text = self.text:sub(1, startPos) .. text .. self.text:sub(endPos + 1)
        self.cursorPosition = startPos + #text
        self.selectStart = nil
        self.selectEnd = nil
    else
        -- Insert text at cursor position
        self.text = self.text:sub(1, self.cursorPosition) .. text .. self.text:sub(self.cursorPosition + 1)
        self.cursorPosition = self.cursorPosition + #text
    end
    
    -- Call callback
    if self.callback then
        self.callback(self.text)
    end
end

function TextInput:deleteText(forward)
    if not self.focused or not self.enabled then return end
    
    -- Delete selected text if any
    if self.selectStart and self.selectEnd and self.selectStart ~= self.selectEnd then
        local startPos = math.min(self.selectStart, self.selectEnd)
        local endPos = math.max(self.selectStart, self.selectEnd)
        
        self.text = self.text:sub(1, startPos) .. self.text:sub(endPos + 1)
        self.cursorPosition = startPos
        self.selectStart = nil
        self.selectEnd = nil
    else
        -- Delete character behind or ahead of cursor
        if forward then
            -- Delete ahead (Delete key)
            if self.cursorPosition < #self.text then
                self.text = self.text:sub(1, self.cursorPosition) .. self.text:sub(self.cursorPosition + 2)
            end
        else
            -- Delete behind (Backspace key)
            if self.cursorPosition > 0 then
                self.text = self.text:sub(1, self.cursorPosition - 1) .. self.text:sub(self.cursorPosition + 1)
                self.cursorPosition = self.cursorPosition - 1
            end
        end
    end
    
    -- Call callback
    if self.callback then
        self.callback(self.text)
    end
end

function TextInput:moveCursor(direction, select)
    if not self.focused or not self.enabled then return end
    
    local oldPosition = self.cursorPosition
    
    if direction == "left" then
        self.cursorPosition = math.max(0, self.cursorPosition - 1)
    elseif direction == "right" then
        self.cursorPosition = math.min(#self.text, self.cursorPosition + 1)
    elseif direction == "home" then
        self.cursorPosition = 0
    elseif direction == "end" then
        self.cursorPosition = #self.text
    end
    
    -- Handle selection
    if select then
        if not self.selectStart then
            self.selectStart = oldPosition
        end
        self.selectEnd = self.cursorPosition
    else
        self.selectStart = nil
        self.selectEnd = nil
    end
    
    -- Reset cursor blink
    self.cursorVisible = true
    self.cursorBlinkTime = 0
    
    -- Adjust text offset to keep cursor visible
    self:adjustTextOffset()
end

function TextInput:selectAll()
    if not self.focused or not self.enabled or #self.text == 0 then return end
    
    self.selectStart = 0
    self.selectEnd = #self.text
    self.cursorPosition = #self.text
    
    -- Reset cursor blink
    self.cursorVisible = true
    self.cursorBlinkTime = 0
end

function TextInput:mousepressed(x, y, button)
    if not self.enabled or button ~= 1 then return false end
    
    if self:contains(x, y) then
        -- Set focus
        self:focus()
        
        -- Set cursor position based on click position
        local textX = x - self.x - self.padding + self.textOffset
        local pos = 0
        
        for i = 1, #self.text do
            local width = self.font:getWidth(self.text:sub(1, i))
            if textX <= width then
                pos = i - 1
                break
            end
            pos = i
        end
        
        self.cursorPosition = pos
        self.selectStart = pos
        self.selectEnd = pos
        
        return true
    else
        -- Lose focus when clicking outside
        self:blur()
        return false
    end
end

function TextInput:mousereleased(x, y, button)
    if not self.enabled or button ~= 1 then return false end
    
    if self.focused and self.pressed then
        -- Update selection end
        local textX = x - self.x - self.padding + self.textOffset
        local pos = 0
        
        for i = 1, #self.text do
            local width = self.font:getWidth(self.text:sub(1, i))
            if textX <= width then
                pos = i - 1
                break
            end
            pos = i
        end
        
        self.selectEnd = pos
        self.cursorPosition = pos
        
        return true
    end
    
    return false
end

function TextInput:mousemoved(x, y, dx, dy)
    if not self.enabled or not self.focused or not love.mouse.isDown(1) then return false end
    
    -- Update selection while dragging
    local textX = x - self.x - self.padding + self.textOffset
    local pos = 0
    
    for i = 1, #self.text do
        local width = self.font:getWidth(self.text:sub(1, i))
        if textX <= width then
            pos = i - 1
            break
        end
        pos = i
    end
    
    self.selectEnd = pos
    self.cursorPosition = pos
    
    return true
end

function TextInput:keypressed(key)
    if not self.focused or not self.enabled then return false end
    
    -- Handle special keys
    if key == "left" then
        self:moveCursor("left", love.keyboard.isDown("lshift", "rshift"))
        return true
    elseif key == "right" then
        self:moveCursor("right", love.keyboard.isDown("lshift", "rshift"))
        return true
    elseif key == "home" then
        self:moveCursor("home", love.keyboard.isDown("lshift", "rshift"))
        return true
    elseif key == "end" then
        self:moveCursor("end", love.keyboard.isDown("lshift", "rshift"))
        return true
    elseif key == "backspace" then
        self:deleteText(false)
        return true
    elseif key == "delete" then
        self:deleteText(true)
        return true
    elseif key == "return" or key == "escape" then
        self:blur()
        return true
    elseif key == "a" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
        self:selectAll()
        return true
    end
    
    return false
end

function TextInput:textinput(text)
    if not self.focused or not self.enabled then return false end
    
    self:insertText(text)
    return true
end

function TextInput:keyreleased(key)
    return self.focused
end

function TextInput:wheelmoved(x, y)
    return false
end

function TextInput:setEnabled(enabled)
    self.enabled = enabled
    
    if not enabled and self.focused then
        self:blur()
    end
end

return TextInput