local Camera = {
    x = 0,
    y = 0,
    scale = 1,
    rotation = 0,
    targetX = 0,
    targetY = 0,
    targetScale = 1,
    shakeAmount = 0,
    shakeDuration = 0,
    shakeFalloff = Constants.CAMERA.SHAKE_DECAY,
    bounds = nil
}

function Camera:init()
    Debug:log("Initializing Camera System")
    
    -- Set default position at the center of the screen
    local width, height = love.graphics.getDimensions()
    self.x = width / 2
    self.y = height / 2
    self.targetX = self.x
    self.targetY = self.y
    
    Debug:log("Camera System initialized")
end

function Camera:update(dt)
    -- Shake effect
    local shakeX, shakeY = 0, 0
    if self.shakeAmount > 0 then
        -- Calculate random offset based on shake amount
        shakeX = love.math.random(-self.shakeAmount, self.shakeAmount)
        shakeY = love.math.random(-self.shakeAmount, self.shakeAmount)
        
        -- Reduce shake amount over time
        self.shakeAmount = math.max(0, self.shakeAmount - (self.shakeFalloff * dt))
    end
    
    -- Smooth camera movement (lerp)
    local lerpSpeed = Constants.CAMERA.LERP_SPEED
    self.x = Helpers.lerp(self.x, self.targetX, lerpSpeed * dt)
    self.y = Helpers.lerp(self.y, self.targetY, lerpSpeed * dt)
    self.scale = Helpers.lerp(self.scale, self.targetScale, Constants.CAMERA.ZOOM_SPEED * dt)
    
    -- Apply shake
    self.x = self.x + shakeX
    self.y = self.y + shakeY
    
    -- Enforce camera bounds if set
    if self.bounds then
        local width, height = love.graphics.getDimensions()
        local halfWidth = (width / 2) / self.scale
        local halfHeight = (height / 2) / self.scale
        
        -- Calculate bounds accounting for scale
        local minX = self.bounds.x + halfWidth
        local maxX = self.bounds.x + self.bounds.width - halfWidth
        local minY = self.bounds.y + halfHeight
        local maxY = self.bounds.y + self.bounds.height - halfHeight
        
        -- Clamp camera position
        self.x = Helpers.clamp(self.x, minX, maxX)
        self.y = Helpers.clamp(self.y, minY, maxY)
        
        -- Also clamp target position
        self.targetX = Helpers.clamp(self.targetX, minX, maxX)
        self.targetY = Helpers.clamp(self.targetY, minY, maxY)
    end
end

function Camera:attach()
    -- Save current transform
    love.graphics.push()
    
    -- Get screen dimensions
    local width, height = love.graphics.getDimensions()
    
    -- Apply camera transformation
    love.graphics.translate(width / 2, height / 2)
    love.graphics.scale(self.scale)
    love.graphics.rotate(self.rotation)
    love.graphics.translate(-self.x, -self.y)
end

function Camera:detach()
    -- Restore previous transform
    love.graphics.pop()
end

function Camera:follow(entity, instant)
    if not entity then return end
    
    -- Set target to entity position
    self.targetX = entity.x
    self.targetY = entity.y
    
    -- Instantly move camera if requested
    if instant then
        self.x = self.targetX
        self.y = self.targetY
    end
end

function Camera:lookAt(x, y, instant)
    -- Set target position
    self.targetX = x
    self.targetY = y
    
    -- Instantly move camera if requested
    if instant then
        self.x = self.targetX
        self.y = self.targetY
    end
end

function Camera:zoom(scale, instant)
    -- Set target scale
    self.targetScale = Helpers.clamp(scale, 0.5, 4)
    
    -- Instantly scale camera if requested
    if instant then
        self.scale = self.targetScale
    end
end

function Camera:zoomIn(amount)
    self:zoom(self.targetScale + (amount or 0.1))
end

function Camera:zoomOut(amount)
    self:zoom(self.targetScale - (amount or 0.1))
end

function Camera:shake(amount, duration)
    -- Set shake parameters
    self.shakeAmount = amount or 5
    self.shakeDuration = duration or 0.5
    self.shakeFalloff = self.shakeAmount / self.shakeDuration
end

function Camera:reset()
    -- Reset camera to default state
    local width, height = love.graphics.getDimensions()
    self.x = width / 2
    self.y = height / 2
    self.scale = 1
    self.rotation = 0
    self.targetX = self.x
    self.targetY = self.y
    self.targetScale = self.scale
    self.shakeAmount = 0
    self.shakeDuration = 0
end

function Camera:setBounds(x, y, width, height)
    -- Set camera movement bounds
    self.bounds = {
        x = x,
        y = y,
        width = width,
        height = height
    }
end

function Camera:screenToWorld(screenX, screenY)
    -- Convert screen coordinates to world coordinates
    local width, height = love.graphics.getDimensions()
    local worldX = (screenX - width / 2) / self.scale + self.x
    local worldY = (screenY - height / 2) / self.scale + self.y
    
    return worldX, worldY
end

function Camera:worldToScreen(worldX, worldY)
    -- Convert world coordinates to screen coordinates
    local width, height = love.graphics.getDimensions()
    local screenX = (worldX - self.x) * self.scale + width / 2
    local screenY = (worldY - self.y) * self.scale + height / 2
    
    return screenX, screenY
end

function Camera:resize(w, h)
    -- whenever the viewport size changes, recenter camera
    self.x = w / 2
    self.y = h / 2
    self.targetX = self.x
    self.targetY = self.y
end

return Camera