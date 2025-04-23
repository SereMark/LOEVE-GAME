-- Physics module for handling collision detection and resolution
-- Handles entity movement, collision detection and resolution
local Physics = {}

function Physics.new()
    local physics = {
        gravity = 800,      -- Gravitational acceleration (pixels/sec^2)
        bodies = {},        -- Collection of physical entities
        debug = false,      -- Visual debug mode toggle
        staticBodies = {},  -- Static bodies (optimized handling)
        dynamicBodies = {}  -- Dynamic bodies (affected by physics)
    }
    
    -- Set up metatable to inherit methods from Physics
    setmetatable(physics, { __index = Physics })
    
    return physics
end

-- Core physics system update loop
function Physics:update(dt)
    -- Reset all dynamic bodies' ground state at the start of each frame
    self:resetGroundStates()
    
    -- Update dynamic bodies with physics
    self:applyPhysics(dt)
    
    -- Handle collisions between bodies
    self:resolveAllCollisions()
end

-- Reset ground contact flags for all dynamic bodies
function Physics:resetGroundStates()
    for _, body in ipairs(self.dynamicBodies) do
        body.onGround = false
    end
end

-- Apply physics forces and update positions
function Physics:applyPhysics(dt)
    for _, body in ipairs(self.dynamicBodies) do
        -- Apply gravity
        body.vy = body.vy + (body.gravity or self.gravity) * dt
        
        -- Store previous position for collision resolution
        body.prevX = body.x
        body.prevY = body.y
        
        -- Update position using velocity and delta time
        body.x = body.x + body.vx * dt
        body.y = body.y + body.vy * dt
        
        -- Handle world boundaries
        self:handleWorldBoundaries(body)
    end
end

-- Handle boundary collisions for a body
function Physics:handleWorldBoundaries(body)
    -- Use entity's world boundaries or fallback to defaults
    local worldWidth = body.worldWidth or 2000
    local worldHeight = body.worldHeight or 1200
    
    -- Handle horizontal boundary constraints
    if body.x < 0 then
        body.x = 0
        body.vx = 0
    elseif body.x + body.width > worldWidth then
        body.x = worldWidth - body.width
        body.vx = 0
    end
    
    -- Get ground height from world properties if available
    local groundHeight = 20 -- Default fallback value
    if body.worldGroundHeight then
        groundHeight = body.worldGroundHeight
    end
    
    -- Handle ground collision with the world boundary
    if body.y + body.height > worldHeight - groundHeight then
        body.y = worldHeight - groundHeight - body.height
        body.vy = 0
        body.onGround = true
    end
end

-- Detect and resolve all collisions
function Physics:resolveAllCollisions()
    local MAX_COLLISION_PASSES = 3
    local collisionPairs = {}
    
    -- First gather all collision pairs to avoid modifying collections during iteration
    
    -- Check dynamic vs static collisions
    for i, dynamicBody in ipairs(self.dynamicBodies) do
        for j, staticBody in ipairs(self.staticBodies) do
            if self:checkCollision(dynamicBody, staticBody) then
                table.insert(collisionPairs, {a = dynamicBody, b = staticBody, isStatic = true})
            end
        end
    end
    
    -- Check dynamic vs dynamic collisions
    for i = 1, #self.dynamicBodies do
        local bodyA = self.dynamicBodies[i]
        
        for j = i + 1, #self.dynamicBodies do
            local bodyB = self.dynamicBodies[j]
            
            if self:checkCollision(bodyA, bodyB) then
                table.insert(collisionPairs, {a = bodyA, b = bodyB, isStatic = false})
            end
        end
    end
    
    -- Then resolve all collisions in passes
    for pass = 1, MAX_COLLISION_PASSES do
        local collisionsResolved = false
        
        for _, pair in ipairs(collisionPairs) do
            local a, b = pair.a, pair.b
            
            -- Skip if either body was removed during previous resolution
            if not a.physics or not b.physics then
                goto continue
            end
            
            -- Re-check collision in case positions changed during resolution
            if self:checkCollision(a, b) then
                local groundDetected = self:resolveCollision(a, b)
                collisionsResolved = true
                
                -- Trigger collision callbacks if implemented
                if pair.isStatic then
                    -- Dynamic vs Static
                    if a.onCollision then pcall(a.onCollision, a, b) end
                else
                    -- Dynamic vs Dynamic
                    if a.onCollision then pcall(a.onCollision, a, b) end
                    if b.onCollision then pcall(b.onCollision, b, a) end
                end
            end
            
            ::continue::
        end
        
        -- If no collisions were resolved in this pass, we're done
        if not collisionsResolved then break end
    end
end

function Physics:addBody(body)
    -- Validate input
    if not body then
        print("Warning: Attempted to add nil body to physics system")
        return nil
    end
    
    -- Ensure required physics properties exist
    body.vx = body.vx or 0
    body.vy = body.vy or 0
    body.onGround = body.onGround or false
    body.width = body.width or 32  -- Default width if not specified
    body.height = body.height or 32  -- Default height if not specified
    
    -- Mark the body as a physics-enabled entity
    body.hasPhysics = true
    
    -- Register entity with physics system
    table.insert(self.bodies, body)
    
    -- Categorize body by type for optimized processing
    if body.isStatic then
        table.insert(self.staticBodies, body)
    else
        table.insert(self.dynamicBodies, body)
    end
    
    -- Back-reference to physics system
    body.physics = self
    
    return body
end

function Physics:removeBody(body)
    -- Unregister entity from all physics collections
    local removed = false
    
    -- Remove from main collection
    for i, b in ipairs(self.bodies) do
        if b == body then
            table.remove(self.bodies, i)
            removed = true
            break
        end
    end
    
    -- Also remove from the appropriate typed collection
    if body.isStatic then
        for i, b in ipairs(self.staticBodies) do
            if b == body then
                table.remove(self.staticBodies, i)
                break
            end
        end
    else
        for i, b in ipairs(self.dynamicBodies) do
            if b == body then
                table.remove(self.dynamicBodies, i)
                break
            end
        end
    end
    
    -- Clear back-reference
    if removed then
        body.physics = nil
    end
    
    return removed
end

function Physics:checkCollision(a, b)
    -- Axis-Aligned Bounding Box (AABB) intersection test
    return a.x < b.x + b.width and
           b.x < a.x + a.width and
           a.y < b.y + b.height and
           b.y < a.y + a.height
end

-- Resolve a collision between two bodies
function Physics:resolveCollision(a, b)
    -- Don't resolve collisions between two static bodies
    if a.isStatic and b.isStatic then
        return false
    end
    
    -- Calculate penetration depth on both axes
    local overlapX = math.min(a.x + a.width, b.x + b.width) - math.max(a.x, b.x)
    local overlapY = math.min(a.y + a.height, b.y + b.height) - math.max(a.y, b.y)
    
    -- Ground detection flag
    local groundDetected = false
    
    -- Case 1: Static vs dynamic collision (static object doesn't move)
    if b.isStatic and not a.isStatic then
        return self:resolveStaticVsDynamicCollision(a, b, overlapX, overlapY)
    elseif a.isStatic and not b.isStatic then
        return self:resolveStaticVsDynamicCollision(b, a, overlapX, overlapY)
    else
        -- Case 2: Both dynamic - split the movement between them
        return self:resolveDynamicVsDynamicCollision(a, b, overlapX, overlapY)
    end
end

-- Handle collision between a static body and a dynamic body
function Physics:resolveStaticVsDynamicCollision(dynamicBody, staticBody, overlapX, overlapY)
    local wasMovingDown = (dynamicBody.vy > 0)
    local groundDetected = false
    
    if overlapX < overlapY then
        -- Horizontal resolution: move dynamic body horizontally
        if dynamicBody.x < staticBody.x then
            dynamicBody.x = dynamicBody.x - overlapX  -- Push left
        else
            dynamicBody.x = dynamicBody.x + overlapX  -- Push right
        end
        dynamicBody.vx = 0
    else
        -- Vertical resolution
        if dynamicBody.y < staticBody.y then
            -- Entity is above the static body (landing on it)
            dynamicBody.y = dynamicBody.y - overlapY  -- Push up
            dynamicBody.vy = 0
            
            -- Ground detection: If we were moving down and hit something below us
            if wasMovingDown then
                dynamicBody.onGround = true
                groundDetected = true
            end
        else
            -- Entity is below the static body (hitting ceiling)
            dynamicBody.y = dynamicBody.y + overlapY  -- Push down
            dynamicBody.vy = 0  -- Stop upward velocity
        end
    end
    
    return groundDetected
end

-- Handle collision between two dynamic bodies
function Physics:resolveDynamicVsDynamicCollision(a, b, overlapX, overlapY)
    local groundDetected = false
    
    if overlapX < overlapY then
        -- Horizontal resolution - split the correction between both bodies
        if a.x < b.x then
            a.x = a.x - overlapX/2  -- Push left
            b.x = b.x + overlapX/2  -- Push right
        else
            a.x = a.x + overlapX/2  -- Push right
            b.x = b.x - overlapX/2  -- Push left
        end
        a.vx = 0
        b.vx = 0
    else
        -- Vertical resolution - split the correction between both bodies
        if a.y < b.y then
            a.y = a.y - overlapY/2  -- Push up
            b.y = b.y + overlapY/2  -- Push down
            a.vy = 0
            b.vy = 0
            a.onGround = true
            groundDetected = true
        else
            a.y = a.y + overlapY/2  -- Push down
            b.y = b.y - overlapY/2  -- Push up
            a.vy = 0
            b.vy = 0
            b.onGround = true
            groundDetected = true
        end
    end
    
    return groundDetected
end



function Physics:debugDraw()
    if not self.debug then return end
    
    -- Draw static bodies in blue
    love.graphics.setColor(0, 0.5, 1, 0.3) -- Translucent blue
    for _, body in ipairs(self.staticBodies) do
        love.graphics.rectangle("line", body.x, body.y, body.width, body.height)
    end
    
    -- Draw dynamic bodies in green
    love.graphics.setColor(0, 1, 0, 0.3) -- Translucent green
    for _, body in ipairs(self.dynamicBodies) do
        love.graphics.rectangle("line", body.x, body.y, body.width, body.height)
        
        -- Show ground state
        if body.onGround then
            love.graphics.setColor(0, 1, 0, 1) -- Solid green for ground indicator
            love.graphics.rectangle("fill", body.x, body.y + body.height - 3, body.width, 3)
        end
    end
    
    -- Restore default color
    love.graphics.setColor(1, 1, 1, 1)
end

return Physics