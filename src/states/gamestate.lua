local Debug = require("src.utils.debug")

local GameState = {
    states = {},
    current = nil
}

-- Register a state
function GameState:register(name, state)
    self.states[name] = state
end

-- Switch to a state
function GameState:switch(name, ...)
    assert(self.states[name], "State '" .. name .. "' does not exist!")
    
    if self.current then
        self.current:exit()
    end
    
    self.current = self.states[name]
    self.current:enter(...)
    
    Debug:log("Switched to state: " .. name)
end

-- Forward love events to current state
function GameState:update(dt)
    if self.current then self.current:update(dt) end
end

function GameState:draw()
    if self.current then self.current:draw() end
end

function GameState:keypressed(key)
    if self.current then self.current:keypressed(key) end
end

function GameState:keyreleased(key)
    if self.current then self.current:keyreleased(key) end
end

function GameState:mousepressed(x, y, button)
    if self.current then self.current:mousepressed(x, y, button) end
end

function GameState:mousereleased(x, y, button)
    if self.current then self.current:mousereleased(x, y, button) end
end

function GameState:resize(w, h)
    if self.current then self.current:resize(w, h) end
end

return GameState