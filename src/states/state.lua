local Class = require("libs.class")
local State = Class:extend()

function State:init(name)
    self.name = name or "BaseState"
end

function State:enter() end
function State:exit() end
function State:update(dt) end
function State:draw() end
function State:keypressed(key) end
function State:keyreleased(key) end
function State:mousepressed(x, y, button) end
function State:mousereleased(x, y, button) end
function State:resize(w, h) end

return State