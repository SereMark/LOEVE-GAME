--[[
    Enemy Module
    
    Handles enemy entities with AI behavior, combat and targeting functionality.
    Controls enemy state, AI decision making, and interactions with the player.
--]]
local Enemy = {}

-- Create a new enemy instance
function Enemy.new(x, y, enemyType)
    -- Validate parameters
    x = x or 300
    y = y or 100
    enemyType = enemyType or "basic"
    
    local enemy = {
        -- Core properties
        x = x,               -- X position
        y = y,               -- Y position
        width = 32,          -- Hitbox width
        height = 32,         -- Hitbox height
        worldWidth = 2000,   -- World boundary X (set by main.lua)
        worldHeight = 1200,  -- World boundary Y (set by main.lua)
        type = "enemy",     -- Entity type identifier
        enemyType = enemyType, -- Specific enemy variant
        
        -- Physics properties
        vx = 0,              -- Velocity X
        vy = 0,              -- Velocity Y
        speed = 80,          -- Movement speed
        onGround = false,    -- Ground contact state
        isStatic = false,    -- Not a static body
        
        -- AI behavior
        targetX = 0,          -- Target X coordinate (usually player)
        targetY = 0,          -- Target Y coordinate
        detectionRange = 250, -- Vision/detection radius
        followDistance = 50,  -- Distance to maintain from target
        state = "idle",     -- Current AI state (idle, chase, attack)
        stateTimer = 0,       -- Timer for state transitions
        thinkTime = 0.5,      -- Time between AI decisions
        
        -- Combat properties
        health = 30,          -- Current health points
        maxHealth = 30,       -- Maximum health points
        damage = 10,          -- Damage dealt to player
        attackRange = 40,     -- Attack reach distance
        attackCooldown = 0,    -- Cooldown between attacks
        direction = 1,        -- Facing direction (1=right, -1=left)
        
        -- Rendering
        color = {1, 0.3, 0.3, 1} -- RGB + Alpha
    }
    
    -- Apply modifications based on enemy type
    if enemyType == "fast" then
        enemy.speed = 120
        enemy.health = 20
        enemy.maxHealth = 20
        enemy.color = {1, 0.5, 0.1, 1} -- Orange
        enemy.jumpForce = -450 -- Fast enemies can jump higher
    elseif enemyType == "heavy" then
        enemy.speed = 50
        enemy.health = 50
        enemy.maxHealth = 50
        enemy.width = 48
        enemy.height = 48
        enemy.damage = 15
        enemy.color = {0.7, 0.2, 0.2, 1} -- Dark red
        enemy.jumpForce = -300 -- Heavy enemies jump less high
    else
        -- Default/basic enemy
        enemy.jumpForce = -350 -- Standard jump force
    end
    
    -- Initialize state variables
    enemy.stunned = false
    enemy.stunTimer = 0
    
    -- Set up metatable to inherit methods from Enemy
    setmetatable(enemy, { __index = Enemy })
    
    return enemy
end

-- Main update function - called every frame
function Enemy:update(dt)
    -- Update stun state if active
    if self.stunned then
        self.stunTimer = self.stunTimer - dt
        if self.stunTimer <= 0 then
            self.stunned = false
        end
    else
        -- Only update AI when not stunned
        self:updateAI(dt)
    end
    
    -- Update combat timers
    if self.attackCooldown > 0 then
        self.attackCooldown = self.attackCooldown - dt
    end
    
    -- Prevent enemies from getting stuck in walls
    if self.onGround and math.abs(self.vx) < 5 then
        -- Small bounce if stuck
        self.vx = (math.random() * 2 - 1) * 20
    end
end

-- Update AI behavior based on current state
function Enemy:updateAI(dt)
    -- Safety check for target coordinates
    if not self.targetX or not self.targetY then
        -- Default to idle behavior if no target is set
        self.state = "idle"
        return
    end
    
    -- Calculate distance to target (typically player)
    local distX = self.targetX - self.x
    local distY = self.targetY - self.y
    local distance = math.sqrt(distX * distX + distY * distY)
    
    -- Update facing direction based on target position
    self.direction = (distX > 0) and 1 or -1
    
    -- Update AI state based on distance and current state
    self.stateTimer = self.stateTimer + dt
    
    if self.stateTimer >= self.thinkTime then
        -- Time to make a new decision
        self.stateTimer = 0
        
        if distance <= self.attackRange then
            self.state = "attack"
        elseif distance <= self.detectionRange then
            self.state = "chase"
        else
            self.state = "idle"
        end
    end
    
    -- Execute behavior based on current state
    if self.state == "chase" then
        -- Only move horizontally if on ground to prevent flying
        if self.onGround then
            self.vx = (distX > 0) and self.speed or -self.speed
        else
            -- Reduce horizontal movement in air for better physics
            self.vx = (distX > 0) and (self.speed * 0.5) or -(self.speed * 0.5)
        end
        
        -- If the target is above and we're on ground, try to jump
        if self.onGround and distY < -self.height and math.abs(distX) < self.width * 3 then
            self.vy = -350 -- Jump velocity
            self.onGround = false
        end
    elseif self.state == "attack" then
        -- Slow down when attacking rather than stopping instantly
        self.vx = self.vx * 0.8
        
        -- Attempt to attack if cooled down
        if self.attackCooldown <= 0 then
            self:attemptAttack()
        end
    else -- idle state
        -- Small random chance of changing direction when idle
        if self.onGround and math.random() < 0.01 then
            self.vx = (math.random() * 2 - 1) * self.speed * 0.3
        else
            -- Gradually slow down when idle
            self.vx = self.vx * 0.95
        end
    end
end

-- Render the enemy
function Enemy:draw()
    love.graphics.push()
    
    -- Render enemy body with direction indicator
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Direction indicator (eye)
    love.graphics.setColor(1, 1, 1, 0.9)
    local eyeOffset = self.direction > 0 and (self.width * 0.7) or (self.width * 0.3)
    love.graphics.circle("fill", self.x + eyeOffset, self.y + self.height * 0.3, 4)
    
    -- Attack indicator (only show during attack state)
    if self.state == "attack" and self.attackCooldown < 0.5 then
        love.graphics.setColor(1, 0, 0, 0.7)
        local attackX = self.x + (self.direction > 0 and self.width or -10)
        love.graphics.rectangle("fill", attackX, self.y, 10, self.height)
    end
    
    -- Render health bar background
    local healthPercentage = self.health / self.maxHealth
    love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    love.graphics.rectangle("fill", self.x, self.y - 10, self.width, 4)
    
    -- Dynamic health bar color (green → yellow → red)
    if healthPercentage > 0.6 then
        love.graphics.setColor(0, 1, 0)       -- Healthy (green)
    elseif healthPercentage > 0.3 then
        love.graphics.setColor(1, 1, 0)       -- Damaged (yellow)
    else
        love.graphics.setColor(1, 0, 0)       -- Critical (red)
    end
    
    -- Render health bar foreground
    love.graphics.rectangle("fill", self.x, self.y - 10, self.width * healthPercentage, 4)
    
    -- State indicator text for debugging
    if false then -- Set to true for debugging
        love.graphics.setColor(1, 1, 1)
        love.graphics.print(self.state, self.x, self.y - 20)
    end
    
    love.graphics.pop()
end

-- Take damage from player attacks
function Enemy:takeDamage(amount)
    -- Validate input
    amount = amount or 0
    if amount <= 0 then return end
    
    -- Reduce health with zero lower bound
    self.health = math.max(0, self.health - amount)
    
    -- Apply knockback in direction away from target
    if self.targetX then
        self.vx = (self.targetX > self.x) and -150 or 150
    else
        -- Random direction if no target
        self.vx = (math.random() > 0.5) and -150 or 150
    end
    self.vy = -100 -- Vertical knockback component
    self.onGround = false -- Ensure we're knocked into the air
    
    -- Temporarily switch to idle state after taking damage
    self.state = "idle"
    self.stateTimer = 0
    
    -- Start a brief stun period
    self.stunned = true
    self.stunTimer = 0.5 -- Half second stun
end

-- Attempt to attack the player if in range
function Enemy:attemptAttack()
    -- This method will be called from the main game loop
    -- when checking for enemy-player combat interactions
    self.attackCooldown = 1.5 -- Reset attack cooldown
    return self.damage -- Return the damage amount
end

-- Check if enemy is in attack range of the target
function Enemy:isInAttackRange(targetX, targetY, targetWidth, targetHeight)
    local distX = math.abs((self.x + self.width/2) - (targetX + targetWidth/2))
    local distY = math.abs((self.y + self.height/2) - (targetY + targetHeight/2))
    
    return distX < self.attackRange and distY < self.height
end

return Enemy