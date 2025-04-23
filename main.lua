--[[
    LÖVE Game - Main Module
    
    Main entry point and game controller that integrates all other modules
    and manages the core game loop. Handles initialization, updates, rendering,
    and input processing for the entire game.
--]]

-- Import required modules
local Game = {
    -- Core modules
    Player = require "src.player",
    Enemy = require "src.enemy",
    Camera = require "src.camera",
    Physics = require "src.physics",
    World = require "src.world",
    
    -- Game state management
    state = "play",       -- Current game state: play, gameover, menu
    previousState = nil,   -- For resuming from pause
    paused = false,        -- Pause state
    score = 0,             -- Player score
    level = 1,             -- Current level number
    debug = false,         -- Debug mode toggle
    
    -- Entity references
    player = nil,          -- Player instance
    enemies = {},          -- Enemy collection
    platforms = {},        -- Platform collection
    world = nil,           -- World instance
    physics = nil          -- Physics system instance
}

function love.load()
    -- Initialize game state
    Game.state = "play"
    Game.paused = false
    Game.score = 0
    Game.lastEnemySpawn = 0  -- Timer for enemy spawning
    
    -- Seed RNG for unpredictable entity placement
    math.randomseed(os.time())
    
    -- Initialize world first (defines the environment)
    Game.world = Game.World.new(2000, 1200) -- width, height
    
    -- Initialize physics system
    Game.physics = Game.Physics.new()
    
    -- Setup debug visualization if needed
    Game.physics.debug = Game.debug
    
    -- Create world boundaries and add them to physics
    Game.world:createBoundaries(Game.physics)
    
    -- Create player entity
    Game.player = Game.Player.new(100, 500)
    Game.player.worldWidth = Game.world.width
    Game.player.worldHeight = Game.world.height
    Game.physics:addBody(Game.player)
    
    -- Setup camera tracking
    Game.camera = Game.Camera.new()
    Game.camera:setTarget(Game.player)
    Game.camera:setBounds(0, 0, Game.world.width, Game.world.height)
    Game.camera:setVerticalOffset(-50) -- Look a bit upward for better visibility
    
    -- Initialize enemy collection
    Game.enemies = {}
    
    -- Generate enemy entities of different types
    local enemyTypes = {"basic", "fast", "heavy"}
    for i = 1, 5 do
        local x = math.random(300, Game.world.width - 100)
        local y = math.random(50, Game.world.height - 300)
        local enemyType = enemyTypes[math.random(1, #enemyTypes)]
        local enemy = Game.Enemy.new(x, y, enemyType)
        enemy.worldWidth = Game.world.width
        enemy.worldHeight = Game.world.height
        Game.physics:addBody(enemy)
        table.insert(Game.enemies, enemy)
    end
    
    -- Generate platforms
    Game.platforms = Game.world:generatePlatforms(Game.physics, 8)
end

function love.update(dt)
    -- Skip updates when paused
    if Game.paused then return end
    
    -- Update based on current game state
    if Game.state == "play" then
        -- Update player entity first (to capture input)
        Game.player:update(dt)
        
        -- Process enemy entities (backwards iteration for safe removal)
        for i = #Game.enemies, 1, -1 do
            local enemy = Game.enemies[i]
            
            -- Update enemy AI targeting
            enemy.targetX, enemy.targetY = Game.player.x, Game.player.y
            
            -- Set ground height for accurate physics
            enemy.worldGroundHeight = Game.world.groundHeight
            
            enemy:update(dt)
            
            -- Handle player attacking enemy
            if Game.player.attacking and Game.player:collidesWith(enemy) then
                -- Player successfully attacks enemy
                enemy:takeDamage(10)
                
                -- Add camera shake for attack impact feedback
                Game.camera:shake(0.3, 0.2)
                
                -- Handle enemy defeat
                if enemy.health <= 0 then
                    Game.physics:removeBody(enemy)
                    table.remove(Game.enemies, i)
                    Game.score = Game.score + 10
                    -- Bigger camera shake on enemy defeat for more satisfaction
                    Game.camera:shake(0.5, 0.3)
                end
            end
            
            -- Handle enemy attacking player
            if not Game.player.invincible and enemy:isInAttackRange(
                Game.player.x, Game.player.y, Game.player.width, Game.player.height
            ) then
                if enemy.attackCooldown <= 0 then
                    local damage = enemy:attemptAttack()
                    Game.player:takeDamage(damage)
                    
                    -- Add camera shake when player takes damage
                    Game.camera:shake(0.4, 0.3)
                end
            end
        end
        
        -- Update physics simulation
        Game.physics:update(dt)
        
        -- Update camera position
        Game.camera:update(dt)
        
        -- Check game over condition
        if Game.player.health <= 0 then
            Game.state = "gameover"
        end
        
        -- Spawn new enemies periodically as game progresses
        Game.lastEnemySpawn = Game.lastEnemySpawn + dt
        if Game.lastEnemySpawn > 10 and #Game.enemies < 8 then  -- Every 10 seconds, cap at 8 enemies
            Game.lastEnemySpawn = 0
            local enemyTypes = {"basic", "fast", "heavy"}
            local x = math.random(300, Game.world.width - 100)
            local y = math.random(50, Game.world.height - 300)
            local enemyType = enemyTypes[math.random(1, #enemyTypes)]
            local enemy = Game.Enemy.new(x, y, enemyType)
            enemy.worldWidth = Game.world.width
            enemy.worldHeight = Game.world.height
            enemy.worldGroundHeight = Game.world.groundHeight
            Game.physics:addBody(enemy)
            table.insert(Game.enemies, enemy)
        end
    end
end

function love.draw()
    -- Begin camera-relative rendering
    Game.camera:attach()
    
    -- Render world (handles background and environment)
    Game.world:draw()
    
    -- Render platforms
    for _, platform in ipairs(Game.platforms) do
        love.graphics.setColor(0.6, 0.4, 0.2) -- Brown for platforms
        love.graphics.rectangle("fill", platform.x, platform.y, platform.width, platform.height)
    end
    
    -- Render gameplay entities
    Game.player:draw()
    
    for _, enemy in ipairs(Game.enemies) do
        enemy:draw()
    end
    
    -- Render physics debug visualization if enabled
    if Game.debug then
        Game.physics:debugDraw()
    end
    
    -- End camera-relative rendering
    Game.camera:detach()
    
    -- Render UI based on current game state
    drawUI()
end

-- UI Drawing function
function drawUI()
    -- Always show score
    love.graphics.setColor(1, 1, 1) -- White
    love.graphics.print("Score: " .. Game.score, 20, 20)
    
    if Game.state == "play" then
        -- Render health bar
        love.graphics.setColor(0.2, 0.2, 0.2, 0.8) -- Dark gray background
        love.graphics.rectangle("fill", 20, 50, 200, 20)
        
        -- Health color varies based on amount
        local healthPercent = Game.player.health / Game.player.maxHealth
        if healthPercent > 0.6 then
            love.graphics.setColor(0.2, 0.8, 0.2) -- Green health
        elseif healthPercent > 0.3 then
            love.graphics.setColor(0.8, 0.8, 0.2) -- Yellow health
        else
            love.graphics.setColor(0.8, 0.2, 0.2) -- Red health (critical)
        end
        
        love.graphics.rectangle("fill", 20, 50, (Game.player.health / Game.player.maxHealth) * 200, 20)
        love.graphics.setColor(1, 1, 1) -- White text
        love.graphics.print("Health: " .. Game.player.health, 30, 52)
    
    elseif Game.state == "gameover" then
        -- Game over overlay
        love.graphics.setColor(0, 0, 0, 0.7) -- Translucent black
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1) -- White text
        love.graphics.printf("GAME OVER\nFinal Score: " .. Game.score .. "\nPress R to restart", 0, 
                          love.graphics.getHeight() / 2 - 30, love.graphics.getWidth(), "center")
    elseif Game.paused then
        -- Pause overlay
        love.graphics.setColor(0, 0, 0, 0.7) -- Translucent black
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
        love.graphics.setColor(1, 1, 1) -- White text
        love.graphics.printf("PAUSED\nPress P to resume\nPress ESC to quit", 0, 
                          love.graphics.getHeight() / 2 - 30, love.graphics.getWidth(), "center")
    end
    
    -- Render performance metrics
    love.graphics.setColor(1, 1, 0) -- Yellow
    love.graphics.print("FPS: " .. love.timer.getFPS(), love.graphics.getWidth() - 100, 20)
    
    -- Debug info if enabled
    if Game.debug then
        love.graphics.setColor(1, 0.5, 0)
        love.graphics.print("Debug Mode\nPlayer position: " .. math.floor(Game.player.x) .. ", " .. math.floor(Game.player.y), 
            love.graphics.getWidth() - 200, 50)
    end
end

function love.keypressed(key)
    -- Global controls
    if key == "escape" then
        love.event.quit()                   -- Exit game
    elseif key == "p" then
        Game.paused = not Game.paused       -- Toggle pause
    elseif key == "r" and Game.state == "gameover" then
        love.load()                         -- Restart game
    elseif key == "f3" then
        Game.debug = not Game.debug         -- Toggle debug mode
        Game.physics.debug = Game.debug     -- Apply to physics system
    end
    
    -- Forward gameplay inputs to player when active
    if Game.state == "play" and not Game.paused then
        Game.player:keypressed(key)
    end
end

function love.keyreleased(key)
    -- Forward key release events to player when active
    if Game.state == "play" and not Game.paused then
        Game.player:keyreleased(key)
    end
end