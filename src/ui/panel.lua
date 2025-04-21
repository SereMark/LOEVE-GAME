local Panel = Class:extend()

function Panel:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    
    -- State
    self.visible = true
    self.hovered = false
    self.pressed = false
    self.passThrough = false
    
    -- Style
    self.backgroundColor = Constants.COLORS.UI_BG
    self.borderColor = Constants.COLORS.UI_BORDER
    self.borderWidth = Constants.UI.BORDER_WIDTH
    self.cornerRadius = 10
    
    -- Children
    self.children = {}
end

function Panel:update(dt)
    -- Update children
    for _, child in ipairs(self.children) do
        if child.visible then
            child:update(dt)
        end
    end
end

function Panel:draw()
    -- Draw background
    love.graphics.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height, self.cornerRadius, self.cornerRadius)
    
    -- Draw border
    love.graphics.setColor(self.borderColor)
    love.graphics.setLineWidth(self.borderWidth)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height, self.cornerRadius, self.cornerRadius)
    
    -- Draw children
    for _, child in ipairs(self.children) do
        if child.visible then
            child:draw()
        end
    end
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

function Panel:contains(x, y)
    return x >= self.x and x <= self.x + self.width and
           y >= self.y and y <= self.y + self.height
end

function Panel:mousepressed(x, y, button)
    -- Check children in reverse order (top to bottom)
    for i = #self.children, 1, -1 do
        local child = self.children[i]
        
        if child.visible and child:contains(x, y) then
            child.pressed = true
            
            -- Call child's event handler
            if child:mousepressed(x, y, button) then
                return true
            end
            
            -- Stop checking if click is handled
            if not child.passThrough then
                return true
            end
        end
    end
    
    return false
end

function Panel:mousereleased(x, y, button)
    -- Check children
    for i = #self.children, 1, -1 do
        local child = self.children[i]
        
        if child.visible and child.pressed then
            child.pressed = false
            
            -- Check if released on same element
            if child:contains(x, y) and child.onClick then
                child:onClick(x, y, button)
            end
            
            -- Call child's event handler
            if child:mousereleased(x, y, button) then
                return true
            end
        end
    end
    
    return false
end

function Panel:mousemoved(x, y, dx, dy)
    -- Update hovered state of children
    for _, child in ipairs(self.children) do
        if child.visible then
            child.hovered = child:contains(x, y)
            
            -- Call child's event handler
            if child.hovered and child:mousemoved(x, y, dx, dy) then
                return true
            end
        end
    end
    
    return false
end

function Panel:keypressed(key)
    -- Pass to children
    for _, child in ipairs(self.children) do
        if child.visible and child:keypressed(key) then
            return true
        end
    end
    
    return false
end

function Panel:keyreleased(key)
    -- Pass to children
    for _, child in ipairs(self.children) do
        if child.visible and child:keyreleased(key) then
            return true
        end
    end
    
    return false
end

function Panel:wheelmoved(x, y)
    -- Pass to children
    for _, child in ipairs(self.children) do
        if child.visible and child.hovered and child:wheelmoved(x, y) then
            return true
        end
    end
    
    return false
end

function Panel:addChild(child)
    -- Add child and adjust its position to be relative to the panel
    child.x = child.x + self.x
    child.y = child.y + self.y
    table.insert(self.children, child)
    return child
end

function Panel:removeChild(child)
    -- Remove child
    for i, c in ipairs(self.children) do
        if c == child then
            table.remove(self.children, i)
            break
        end
    end
end

function Panel:clearChildren()
    self.children = {}
end

function Panel:setVisible(visible)
    self.visible = visible
end

return Panel