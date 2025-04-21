local UI = {
    elements = {},
    fonts = {},
    activeElement = nil,
    hoveredElement = nil,
    visible = true,
    layers = {},
    theme = {
        background = Constants.COLORS.UI_BG,
        border = Constants.COLORS.UI_BORDER,
        text = Constants.COLORS.WHITE,
        highlight = Constants.COLORS.UI_HIGHLIGHT,
        disabled = Constants.COLORS.GRAY
    }
}

function UI:init()
    Debug:log("Initializing UI System")
    
    -- Clear elements
    self.elements = {}
    
    -- Create layers
    for i = 1, 10 do
        self.layers[i] = {}
    end
    
    -- Load UI elements
    self.Button = require("src.ui.button")
    self.Panel = require("src.ui.panel")
    self.Label = require("src.ui.label")
    self.Image = require("src.ui.image")
    self.Slider = require("src.ui.slider")
    self.Checkbox = require("src.ui.checkbox")
    self.TextInput = require("src.ui.textinput")
    self.ProgressBar = require("src.ui.progressbar")
    
    Debug:log("UI System initialized")
end

function UI:update(dt)
    -- Get mouse position
    local mouseX, mouseY = Input:getMousePosition()
    
    -- Reset hovered element
    self.hoveredElement = nil
    
    -- Update all UI elements (in reverse for proper event bubbling)
    for layer = 10, 1, -1 do
        for i = #self.layers[layer], 1, -1 do
            local element = self.layers[layer][i]
            
            -- Skip hidden elements
            if element.visible then
                -- Update element
                element:update(dt)
                
                -- Check hover
                if element:contains(mouseX, mouseY) then
                    element.hovered = true
                    
                    -- Set as hovered element if none set yet
                    if not self.hoveredElement then
                        self.hoveredElement = element
                    end
                else
                    element.hovered = false
                end
            end
        end
    end
end

function UI:draw()
    if not self.visible then return end
    
    -- Draw all UI elements by layer
    for layer = 1, 10 do
        for _, element in ipairs(self.layers[layer]) do
            if element.visible then
                element:draw()
            end
        end
    end
end

function UI:keypressed(key)
    -- Skip if UI is hidden
    if not self.visible then return end
    
    -- Send event to active element first
    if self.activeElement and self.activeElement.visible then
        if self.activeElement:keypressed(key) then
            return true
        end
    end
    
    -- Send to hovered element
    if self.hoveredElement and self.hoveredElement.visible then
        if self.hoveredElement:keypressed(key) then
            return true
        end
    end
    
    return false
end

function UI:keyreleased(key)
    -- Skip if UI is hidden
    if not self.visible then return end
    
    -- Send event to active element first
    if self.activeElement and self.activeElement.visible then
        if self.activeElement:keyreleased(key) then
            return true
        end
    end
    
    return false
end

function UI:mousepressed(x, y, button)
    -- Skip if UI is hidden
    if not self.visible then return end
    
    -- Clear active element
    self.activeElement = nil
    
    -- Check elements in reverse order (top to bottom)
    for layer = 10, 1, -1 do
        for i = #self.layers[layer], 1, -1 do
            local element = self.layers[layer][i]
            
            -- Skip hidden elements
            if element.visible and element:contains(x, y) then
                element.pressed = true
                
                -- Set as active element
                self.activeElement = element
                
                -- Call element's event handler
                if element:mousepressed(x, y, button) then
                    return true
                end
                
                -- Stop checking if click is handled
                if not element.passThrough then
                    return true
                end
            end
        end
    end
    
    return false
end

function UI:mousereleased(x, y, button)
    -- Skip if UI is hidden
    if not self.visible then return end
    
    -- Check for click on active element
    if self.activeElement and self.activeElement.visible then
        local element = self.activeElement
        element.pressed = false
        
        -- Check if released on same element
        if element:contains(x, y) then
            -- Call click handler
            if element.onClick then
                element:onClick(x, y, button)
            end
        end
        
        -- Call element's event handler
        if element:mousereleased(x, y, button) then
            return true
        end
    end
    
    -- Reset all pressed states
    for layer = 1, 10 do
        for _, element in ipairs(self.layers[layer]) do
            element.pressed = false
        end
    end
    
    return false
end

function UI:mousemoved(x, y, dx, dy)
    -- Skip if UI is hidden
    if not self.visible then return end
    
    -- Send event to active element first
    if self.activeElement and self.activeElement.visible then
        if self.activeElement:mousemoved(x, y, dx, dy) then
            return true
        end
    end
    
    return false
end

function UI:wheelmoved(x, y)
    -- Skip if UI is hidden
    if not self.visible then return end
    
    -- Send event to hovered element first
    if self.hoveredElement and self.hoveredElement.visible then
        if self.hoveredElement:wheelmoved(x, y) then
            return true
        end
    end
    
    return false
end

function UI:resize(w, h)
    -- Notify all elements of resize
    for layer = 1, 10 do
        for _, element in ipairs(self.layers[layer]) do
            if element.onResize then
                element:onResize(w, h)
            end
        end
    end
end

function UI:addElement(element, layer)
    -- Default to layer 5
    layer = layer or 5
    
    -- Add to appropriate layer
    table.insert(self.layers[layer], element)
    element.layer = layer
    
    return element
end

function UI:removeElement(element)
    -- Remove from layer
    if element and element.layer then
        for i, el in ipairs(self.layers[element.layer]) do
            if el == element then
                table.remove(self.layers[element.layer], i)
                break
            end
        end
    end
end

function UI:clearElements()
    -- Clear all elements
    for layer = 1, 10 do
        self.layers[layer] = {}
    end
    
    self.activeElement = nil
    self.hoveredElement = nil
end

function UI:setVisible(visible)
    self.visible = visible
end

function UI:isVisible()
    return self.visible
end

function UI:createButton(x, y, width, height, text, callback, layer)
    local button = self.Button:new(x, y, width, height, text, callback)
    return self:addElement(button, layer)
end

function UI:createPanel(x, y, width, height, layer)
    local panel = self.Panel:new(x, y, width, height)
    return self:addElement(panel, layer)
end

function UI:createLabel(x, y, text, font, color, layer)
    local label = self.Label:new(x, y, text, font, color)
    return self:addElement(label, layer)
end

function UI:createImage(x, y, image, scale, layer)
    local img = self.Image:new(x, y, image, scale)
    return self:addElement(img, layer)
end

function UI:createSlider(x, y, width, height, min, max, value, callback, layer)
    local slider = self.Slider:new(x, y, width, height, min, max, value, callback)
    return self:addElement(slider, layer)
end

function UI:createCheckbox(x, y, size, checked, callback, layer)
    local checkbox = self.Checkbox:new(x, y, size, checked, callback)
    return self:addElement(checkbox, layer)
end

function UI:createTextInput(x, y, width, height, text, placeholder, callback, layer)
    local textinput = self.TextInput:new(x, y, width, height, text, placeholder, callback)
    return self:addElement(textinput, layer)
end

function UI:createProgressBar(x, y, width, height, value, maxValue, color, layer)
    local progressbar = self.ProgressBar:new(x, y, width, height, value, maxValue, color)
    return self:addElement(progressbar, layer)
end

function UI:setTheme(theme)
    -- Update theme with new values
    for key, value in pairs(theme) do
        self.theme[key] = value
    end
end

return UI