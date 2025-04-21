local Input = {
    keys = {},
    mouseButtons = {},
    mouseX = 0,
    mouseY = 0,
    mouseDeltaX = 0,
    mouseDeltaY = 0,
    mouseWheel = 0,
    gamepads = {},
    bindings = {},
    virtualInputs = {},
    deadzone = 0.25,
}

function Input:init()
    Debug:log("Initializing Input Manager")
    
    -- Set initial state
    self.keys = {}
    self.mouseButtons = {}
    self.mouseX, self.mouseY = love.mouse.getPosition()
    self.mouseDeltaX, self.mouseDeltaY = 0, 0
    
    -- Initialize gamepads
    self.gamepads = love.joystick.getJoysticks()
    Debug:log("Found " .. #self.gamepads .. " gamepads")
    
    -- Define default input bindings
    self:setDefaultBindings()
    
    -- Try to load custom bindings
    local settings = SaveLoad:loadSettings()
    if settings and settings.bindings then
        self.bindings = settings.bindings
    end
    
    Debug:log("Input Manager initialized")
end

function Input:update(dt)
    -- Update mouse delta and reset wheel
    self.mouseDeltaX, self.mouseDeltaY = 0, 0
    self.mouseWheel = 0
    
    -- Update virtual inputs
    for name, virtualInput in pairs(self.virtualInputs) do
        virtualInput.previousValue = virtualInput.value
        virtualInput.value = self:getVirtualInputValue(name)
        virtualInput.pressed = not virtualInput.previousValue and virtualInput.value
        virtualInput.released = virtualInput.previousValue and not virtualInput.value
    end
end

function Input:setDefaultBindings()
    self.bindings = {
        -- Movement
        moveUp = {"up", "w", "dpup"},
        moveDown = {"down", "s", "dpdown"},
        moveLeft = {"left", "a", "dpleft"},
        moveRight = {"right", "d", "dpright"},
        
        -- Actions
        attack = {"space", "x", "buttonx"},
        jump = {"space", "z", "buttona"},
        dash = {"lshift", "c", "buttonb"},
        interact = {"e", "v", "buttony"},
        
        -- Menu navigation
        confirm = {"return", "space", "buttona"},
        cancel = {"escape", "backspace", "buttonb"},
        
        -- UI
        pause = {"escape", "p", "start"},
        menu = {"tab", "m", "back"},
        
        -- Debug
        debug = {"f1"}
    }
    
    -- Create virtual inputs for analog movement
    self.virtualInputs = {
        moveX = { value = 0, previousValue = 0, pressed = false, released = false },
        moveY = { value = 0, previousValue = 0, pressed = false, released = false },
        aimX = { value = 0, previousValue = 0, pressed = false, released = false },
        aimY = { value = 0, previousValue = 0, pressed = false, released = false }
    }
    
    -- Create additional boolean virtual inputs based on bindings
    for action, _ in pairs(self.bindings) do
        if not self.virtualInputs[action] then
            self.virtualInputs[action] = { value = false, previousValue = false, pressed = false, released = false }
        end
    end
end

function Input:isDown(action)
    -- Check virtual input value
    if self.virtualInputs[action] then
        return self.virtualInputs[action].value
    else
        -- Check direct binding
        return self:isBindingDown(action)
    end
end

function Input:isPressed(action)
    -- Check if virtual input was just pressed
    if self.virtualInputs[action] then
        return self.virtualInputs[action].pressed
    else
        return false
    end
end

function Input:isReleased(action)
    -- Check if virtual input was just released
    if self.virtualInputs[action] then
        return self.virtualInputs[action].released
    else
        return false
    end
end

function Input:isBindingDown(action)
    local bindings = self.bindings[action]
    if not bindings then return false end
    
    for _, input in ipairs(bindings) do
        -- Check keyboard
        if self.keys[input] then
            return true
        end
        
        -- Check mouse buttons
        if input == "mouseprimary" and self.mouseButtons[1] then
            return true
        elseif input == "mousesecondary" and self.mouseButtons[2] then
            return true
        elseif input == "mousemiddle" and self.mouseButtons[3] then
            return true
        end
        
        -- Check gamepad
        for _, gamepad in ipairs(self.gamepads) do
            if input:match("^button") and gamepad:isGamepadDown(input) then
                return true
            elseif input:match("^dp") and gamepad:isGamepadDown(input) then
                return true
            elseif input == "leftx+" and gamepad:getGamepadAxis("leftx") > self.deadzone then
                return true
            elseif input == "leftx-" and gamepad:getGamepadAxis("leftx") < -self.deadzone then
                return true
            elseif input == "lefty+" and gamepad:getGamepadAxis("lefty") > self.deadzone then
                return true
            elseif input == "lefty-" and gamepad:getGamepadAxis("lefty") < -self.deadzone then
                return true
            elseif input == "rightx+" and gamepad:getGamepadAxis("rightx") > self.deadzone then
                return true
            elseif input == "rightx-" and gamepad:getGamepadAxis("rightx") < -self.deadzone then
                return true
            elseif input == "righty+" and gamepad:getGamepadAxis("righty") > self.deadzone then
                return true
            elseif input == "righty-" and gamepad:getGamepadAxis("righty") < -self.deadzone then
                return true
            elseif input == "triggerleft" and gamepad:getGamepadAxis("triggerleft") > self.deadzone then
                return true
            elseif input == "triggerright" and gamepad:getGamepadAxis("triggerright") > self.deadzone then
                return true
            end
        end
    end
    
    return false
end

function Input:getVirtualInputValue(name)
    if name == "moveX" then
        local value = 0
        if self:isBindingDown("moveRight") then value = value + 1 end
        if self:isBindingDown("moveLeft") then value = value - 1 end
        
        -- Add gamepad analog input
        for _, gamepad in ipairs(self.gamepads) do
            local axisValue = gamepad:getGamepadAxis("leftx")
            if math.abs(axisValue) > self.deadzone then
                value = axisValue
            end
        end
        
        return value
    elseif name == "moveY" then
        local value = 0
        if self:isBindingDown("moveDown") then value = value + 1 end
        if self:isBindingDown("moveUp") then value = value - 1 end
        
        -- Add gamepad analog input
        for _, gamepad in ipairs(self.gamepads) do
            local axisValue = gamepad:getGamepadAxis("lefty")
            if math.abs(axisValue) > self.deadzone then
                value = axisValue
            end
        end
        
        return value
    elseif name == "aimX" then
        -- Use right stick for aiming
        for _, gamepad in ipairs(self.gamepads) do
            local axisValue = gamepad:getGamepadAxis("rightx")
            if math.abs(axisValue) > self.deadzone then
                return axisValue
            end
        end
        return 0
    elseif name == "aimY" then
        -- Use right stick for aiming
        for _, gamepad in ipairs(self.gamepads) do
            local axisValue = gamepad:getGamepadAxis("righty")
            if math.abs(axisValue) > self.deadzone then
                return axisValue
            end
        end
        return 0
    else
        -- Boolean virtual inputs
        return self:isBindingDown(name)
    end
end

function Input:getMousePosition()
    return self.mouseX, self.mouseY
end

function Input:getMouseDelta()
    return self.mouseDeltaX, self.mouseDeltaY
end

function Input:getMouseWorldPosition()
    -- Convert screen coordinates to world coordinates with camera transformation
    return Camera:screenToWorld(self.mouseX, self.mouseY)
end

function Input:keypressed(key)
    self.keys[key] = true
end

function Input:keyreleased(key)
    self.keys[key] = false
end

function Input:mousepressed(x, y, button)
    self.mouseButtons[button] = true
end

function Input:mousereleased(x, y, button)
    self.mouseButtons[button] = false
end

function Input:mousemoved(x, y, dx, dy)
    self.mouseDeltaX, self.mouseDeltaY = dx, dy
    self.mouseX, self.mouseY = x, y
end

function Input:wheelmoved(x, y)
    self.mouseWheel = y
end

function Input:gamepadpressed(joystick, button)
    -- Update gamepad list
    self.gamepads = love.joystick.getJoysticks()
end

function Input:gamepadreleased(joystick, button)
    -- Update gamepad list
    self.gamepads = love.joystick.getJoysticks()
end

function Input:rebindAction(action, index, input)
    if not self.bindings[action] then
        self.bindings[action] = {}
    end
    
    self.bindings[action][index] = input
    
    -- Save bindings
    SaveLoad:saveSettings({
        bindings = self.bindings
    })
end

function Input:resetBindings()
    self:setDefaultBindings()
    
    -- Save default bindings
    SaveLoad:saveSettings({
        bindings = self.bindings
    })
end

return Input