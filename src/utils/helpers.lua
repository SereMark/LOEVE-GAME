local Helpers = {}

-- Print a formatted message
function Helpers.printf(msg, ...)
    return string.format(msg, ...)
end

-- Check if a point is inside a rectangle
function Helpers.pointInRect(px, py, rx, ry, rw, rh)
    return px >= rx and px <= rx + rw and py >= ry and py <= ry + rh
end

-- Clamp a value between min and max
function Helpers.clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

-- Linear interpolation
function Helpers.lerp(a, b, t)
    return a + (b - a) * t
end

-- Generate a random color
function Helpers.randomColor()
    return {math.random(), math.random(), math.random(), 1}
end

return Helpers