local Class = {}
Class.__index = Class

function Class:new(...)
    local instance = setmetatable({}, self)
    if instance.init then instance:init(...) end
    return instance
end

function Class:extend()
    local subclass = {}
    for k, v in pairs(self) do
        if k:find("__") == 1 then
            subclass[k] = v
        end
    end
    subclass.__index = subclass
    subclass.super = self
    setmetatable(subclass, self)
    return subclass
end

return Class