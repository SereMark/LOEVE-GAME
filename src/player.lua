--[[
    Player Module
    
    Handles player entity with movement, combat and collision functionality.
    Controls player state, rendering, and input handling.
--]]
local Player = {}

-- Create a new player instance
function Player.new(x, y)
    local player = {
        -- Core properties
        x = x or 100,        -- X position
        y = y or 100,        -- Y position
        width = 32,          -- Hitbox width
        height = 64,         -- Hitbox height
        worldWidth = 2000,   -- World boundary X (set by main.lua)
        worldHeight = 1200,  -- World boundary Y (set by main.lua)
        
        -- Physics 
        vx = 0,              -- Velocity X
        vy = 0,              -- Velocity Y
        speed = 200,         -- Movement speed
        jumpForce = -450,    -- Jump velocity (negative = up)
        onGround = false,    -- Ground contact state
        jumpsCount = 0,      -- Track number of jumps (for double jump potential)
        maxJumps = 2,        -- Maximum number of jumps allowed before landing
        jumpBufferTimer = 0, -- Time to buffer jump input when in air
        jumpBufferDuration = 0.15, -- How long to buffer jump input (seconds)
        coyoteTimer = 0,     -- Time after leaving platform to still jump
        coyoteDuration = 0.1, -- How long coyote time lasts (seconds)
        wasOnGround = false, -- Previous frame ground state for coyote time
        
        -- Combat properties
        health = 100,        -- Current health points
        maxHealth = 100,     -- Maximum health points
        attacking = false,   -- Attack state
        attackTimer = 0,     -- Current attack time
        attackDuration = 0.3,-- Attack animation length
        attackCooldown = 0,  -- Cooldown between attacks
        direction = 1,       -- Facing direction (1=right, -1=left)
        invincible = false,  -- Damage immunity state
        invincibleTimer = 0, -- Damage immunity timer
        invincibleDuration = 1.0, -- Seconds of invincibility after damage
        
        -- Rendering
        color = {0.2, 0.6, 1, 1}, -- RGB + Alpha
        afterimages = {},    -- Trail effect when moving
        afterimageTimer = 0, -- Timer for creating afterimages
        afterimageDuration = 0.1 -- Time between afterimage creation
    }
    
    -- Set up metatable to inherit methods from Player
    setmetatable(player, { __index = Player })
    
    return player
end

-- Update player state - called every frame
function Player:update(dt)
    -- Store previous ground state for coyote time
    self.wasOnGround = self.onGround
    
    -- Handle player input
    self:handleInput(dt)
    
    -- Update combat states
    self:updateCombatState(dt)
    
    -- Reset jump count when landing
    if self.onGround then
        self.jumpsCount = 0
    end
    
    -- Update jump buffer timer
    if self.jumpBufferTimer > 0 then
        self.jumpBufferTimer = self.jumpBufferTimer - dt
        
        -- If we hit the ground while buffer is active, jump immediately
        if self.onGround then
            self:jump()
        end
    end
    
    -- Handle coyote time (grace period for jumping after leaving platform)
    if self.wasOnGround and not self.onGround then
        self.coyoteTimer = self.coyoteDuration
    end
    
    if self.coyoteTimer > 0 then
        self.coyoteTimer = self.coyoteTimer - dt
    end
    
    -- Visual effects: afterimages for fast movement
    self.afterimageTimer = self.afterimageTimer - dt
    if self.afterimageTimer <= 0 and (math.abs(self.vx) > self.speed * 0.5 or math.abs(self.vy) > 200) then
        self:createAfterimage()
        self.afterimageTimer = self.afterimageDuration
    end
    
    -- Update afterimages
    for i = #self.afterimages, 1, -1 do
        local afterimage = self.afterimages[i]
        afterimage.alpha = afterimage.alpha - dt * 2
        if afterimage.alpha <= 0 then
            table.remove(self.afterimages, i)
        end
    end
end

-- Process player input for movement
function Player:handleInput(dt)
    -- Process horizontal movement from input
    self.vx = 0
    local left = love.keyboard.isDown("left", "a")
    local right = love.keyboard.isDown("right", "d")
    
    if left and not right then
        self.vx = -self.speed
        self.direction = -1
    elseif right and not left then
        self.vx = self.speed
        self.direction = 1
    end
    
    -- Air control - slightly reduced movement speed in air for better feel
    if not self.onGround and self.vx ~= 0 then
        self.vx = self.vx * 0.9
    end
    
    -- Continuous jump by holding the key
    if love.keyboard.isDown("space", "w", "up") and self.jumpBufferTimer > 0 and self.onGround then
        self:jump()
    end
end

-- Update combat-related timers and states
function Player:updateCombatState(dt)
    -- Attack state
    if self.attacking then
        self.attackTimer = self.attackTimer + dt
        if self.attackTimer >= self.attackDuration then
            self.attacking = false
            self.attackTimer = 0
        end
    end
    
    -- Invincibility after taking damage
    if self.invincible then
        self.invincibleTimer = self.invincibleTimer + dt
        if self.invincibleTimer >= self.invincibleDuration then
            self.invincible = false
            self.invincibleTimer = 0
        end
    end
    
    -- Attack cooldown
    if self.attackCooldown > 0 then
        self.attackCooldown = self.attackCooldown - dt
    end
end

function Player:draw()
    -- Draw motion afterimages first (behind player)
    for _, afterimage in ipairs(self.afterimages) do
        love.graphics.push()
        love.graphics.setColor(self.color[1], self.color[2], self.color[3], afterimage.alpha * 0.3)
        love.graphics.rectangle("fill", afterimage.x, afterimage.y, self.width, self.height)
        love.graphics.pop()
    end
    
    love.graphics.push()
    
    -- Handle visual state (flashing during invincibility)
    if self.invincible and math.floor(self.invincibleTimer * 10) % 2 == 0 then
        love.graphics.setColor(1, 1, 1, 0.5) -- Flash white
    else
        love.graphics.setColor(self.color)
    end
    
    -- Render player body
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    
    -- Add face direction indicator
    love.graphics.setColor(1, 1, 1, 0.8)
    local eyeX = self.x + (self.direction > 0 and (self.width * 0.7) or (self.width * 0.3))
    love.graphics.circle("fill", eyeX, self.y + self.height * 0.25, 4)
    
    -- Render attack hitbox when attacking
    if self.attacking then
        love.graphics.setColor(1, 0, 0, 0.5) -- Translucent red
        local attackX = self.x + (self.direction > 0 and self.width or -50)
        love.graphics.rectangle("fill", attackX, self.y, 50, self.height)
    end
    
    -- Health bar
    local healthPercentage = self.health / self.maxHealth
    love.graphics.setColor(0.2, 0.2, 0.2, 0.8)
    love.graphics.rectangle("fill", self.x, self.y - 10, self.width, 4)
    
    -- Color gradient based on health level
    if healthPercentage > 0.6 then
        love.graphics.setColor(0, 1, 0)
    elseif healthPercentage > 0.3 then
        love.graphics.setColor(1, 1, 0)
    else
        love.graphics.setColor(1, 0, 0)
    end
    
    love.graphics.rectangle("fill", self.x, self.y - 10, self.width * healthPercentage, 4)
    
    love.graphics.pop()
end

-- Make the player jump
function Player:jump()
    -- Check if we can jump (either on ground or have air jumps left)
    if self.onGround or self.jumpsCount < self.maxJumps then
        -- Apply jump velocity
        self.vy = self.jumpForce
        
        -- Ensure we clear the ground to prevent sticking
        if self.onGround then
            self.y = self.y - 2  -- Small pixel boost to clear ground
        end
        
        -- Count this jump
        self.jumpsCount = self.jumpsCount + 1
        
        -- No longer considered on ground after jumping
        self.onGround = false
        
        -- Reset jump buffer when a jump happens
        self.jumpBufferTimer = 0
    elseif not self.onGround then
        -- If in air and can't jump, store the request in the buffer
        self.jumpBufferTimer = self.jumpBufferDuration
    end
end

-- Initiate player attack
function Player:attack()
    -- Only allow attack if not currently attacking and cooldown is over
    if not self.attacking and self.attackCooldown <= 0 then
        self.attacking = true
        self.attackTimer = 0
        self.attackCooldown = 0.5  -- Half-second cooldown between attacks
    end
end

-- Take damage from enemies or hazards
function Player:takeDamage(amount)
    -- Process damage only when not in invincible state
    if not self.invincible then
        -- Reduce health with lower bound of zero
        self.health = math.max(0, self.health - amount)
        
        -- Apply knockback based on facing direction
        self.vy = -200  -- Upward boost
        self.vx = -self.direction * 150  -- Push back in opposite direction
        
        -- Enter invincibility frames
        self.invincible = true
        self.invincibleTimer = 0
    end
end

function Player:collidesWith(entity)
    -- If attacking, check if the attack hitbox collides with the entity
    if self.attacking then
        local attackX = self.x + (self.direction > 0 and self.width or -50)
        local attackWidth = 50  -- Match the width used in the draw function
        
        -- Attack hitbox AABB collision detection
        local attackHit = 
            attackX < entity.x + entity.width and
            entity.x < attackX + attackWidth and
            self.y < entity.y + entity.height and
            entity.y < self.y + self.height
            
        if attackHit then
            return true
        end
    end
    
    -- Standard body AABB collision detection
    return self.x < entity.x + entity.width and
           entity.x < self.x + self.width and
           self.y < entity.y + entity.height and
           entity.y < self.y + self.height
end

function Player:keypressed(key)
    -- Handle jump and attack inputs
    if key == "space" or key == "w" or key == "up" then
        -- Allow jump if either on ground or in coyote time
        if self.onGround or self.coyoteTimer > 0 or self.jumpsCount < self.maxJumps then
            self:jump()
        else
            -- Buffer the jump for a short time if we can't jump right now
            self.jumpBufferTimer = self.jumpBufferDuration
        end
    elseif key == "z" or key == "j" then
        self:attack()
    end
end

function Player:keyreleased(key)
    -- Currently no key release actions needed
end

-- Create a visual afterimage at the current position
function Player:createAfterimage()
    local afterimage = {
        x = self.x,
        y = self.y,
        alpha = 1.0 -- Starting opacity
    }
    table.insert(self.afterimages, afterimage)
    
    -- Limit the number of afterimages to prevent memory issues
    if #self.afterimages > 5 then
        table.remove(self.afterimages, 1)
    end
end

return Player