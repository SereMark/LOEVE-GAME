-- Camera module for tracking and rendering game entities
local Camera = {}

function Camera.new()
    local camera = {
        x = 0,              -- Camera position X coordinate
        y = 0,              -- Camera position Y coordinate
        scale = 1,          -- Zoom factor
        targetScale = 1,    -- Scale to interpolate toward
        target = nil,       -- Entity to follow
        smoothness = 0.1,   -- Interpolation factor (0.1 = smooth, 1.0 = instant)
        verticalOffset = 0, -- Vertical offset to look ahead in movement direction
        bounds = nil,       -- Camera bounds (world limits)
        shakeData = {       -- Screen shake properties
            intensity = 0,      -- Current shake intensity
            duration = 0,        -- How long to shake
            trauma = 0,          -- Trauma level (squared for intensity)
            frequency = 0.5,      -- Shake frequency
            offsetX = 0,          -- Current X offset from shake
            offsetY = 0           -- Current Y offset from shake
        }
    }
    
    -- Set up metatable to inherit methods from Camera
    setmetatable(camera, { __index = Camera })
    
    return camera
end

function Camera:update(dt)
    -- Update screen shake if active
    self:updateShake(dt)
    
    -- Follow target if one exists
    if self.target then
        -- Calculate target's center position
        local targetX = self.target.x + self.target.width / 2
        local targetY = self.target.y + self.target.height / 2
        
        -- Look-ahead based on target velocity and direction
        if self.target.vx then
            -- Add horizontal look-ahead based on movement direction
            targetX = targetX + (self.target.vx * 0.5)
        end
        
        -- Add vertical offset for better gameplay visibility (show more of what's ahead)
        targetY = targetY + self.verticalOffset
        
        -- Apply time-consistent interpolation with 60fps normalization
        self.x = self.x + (targetX - self.x) * self.smoothness * 60 * dt
        self.y = self.y + (targetY - self.y) * self.smoothness * 60 * dt
        
        -- Smoothly interpolate scale
        self.scale = self.scale + (self.targetScale - self.scale) * self.smoothness * 60 * dt
        
        -- Enforce camera bounds if set
        if self.bounds then
            local screenWidth = love.graphics.getWidth() / self.scale / 2
            local screenHeight = love.graphics.getHeight() / self.scale / 2
            
            -- Clamp to world boundaries
            self.x = math.max(self.bounds.x + screenWidth, 
                     math.min(self.bounds.width - screenWidth, self.x))
            self.y = math.max(self.bounds.y + screenHeight, 
                     math.min(self.bounds.height - screenHeight, self.y))
        end
    end
end

function Camera:setTarget(entity)
    self.target = entity
end

function Camera:attach()
    -- Begin camera transformation sequence
    love.graphics.push()
    
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    
    -- Transform coordinate system: center, scale, then offset by camera position
    love.graphics.translate(screenWidth / 2, screenHeight / 2)
    love.graphics.scale(self.scale, self.scale)
    love.graphics.translate(-self.x + self.shakeData.offsetX, -self.y + self.shakeData.offsetY)
end

function Camera:detach()
    -- Restore original coordinate system
    love.graphics.pop()
end

-- Set camera bounds (world limits)
function Camera:setBounds(x, y, width, height)
    self.bounds = {
        x = x or 0,
        y = y or 0,
        width = width or love.graphics.getWidth(),
        height = height or love.graphics.getHeight()
    }
end

-- Set vertical offset for better gameplay visibility
function Camera:setVerticalOffset(offset)
    self.verticalOffset = offset or 0
end

-- Set zoom level with smooth transition
function Camera:setZoom(scale)
    self.targetScale = scale or 1
end

-- Add screen shake effect
function Camera:shake(intensity, duration)
    intensity = math.min(intensity or 0.5, 1.0) -- Clamp to max 1.0
    self.shakeData.trauma = math.max(self.shakeData.trauma, intensity)
    self.shakeData.duration = math.max(self.shakeData.duration, duration or 0.5)
end

-- Update screen shake effect
function Camera:updateShake(dt)
    if self.shakeData.duration > 0 then
        self.shakeData.duration = self.shakeData.duration - dt
        
        -- Calculate shake intensity based on trauma
        self.shakeData.intensity = self.shakeData.trauma * self.shakeData.trauma
        
        -- Apply perlin noise for smoother, randomized shake
        local time = love.timer.getTime() * self.shakeData.frequency
        self.shakeData.offsetX = self.shakeData.intensity * 10 * (math.sin(time * 5) + math.sin(time * 15) * 0.5)
        self.shakeData.offsetY = self.shakeData.intensity * 10 * (math.cos(time * 10) + math.cos(time * 5) * 0.5)
        
        -- Decay trauma over time
        self.shakeData.trauma = math.max(0, self.shakeData.trauma - dt * 2)
        
        -- Reset shake when duration expires
        if self.shakeData.duration <= 0 then
            self.shakeData.offsetX = 0
            self.shakeData.offsetY = 0
            self.shakeData.intensity = 0
            self.shakeData.trauma = 0
        end
    end
end

return Camera