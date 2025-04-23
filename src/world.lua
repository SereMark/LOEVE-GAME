-- World module for environment definition and level creation
local World = {}

-- Create a new world instance
function World.new(width, height)
    local world = {
        width = width or 2000,     -- Level width (pixels)
        height = height or 1200,   -- Level height (pixels)
        groundHeight = 20,         -- Height of ground platform
        boundaries = {}            -- Collection of world boundaries
    }
    
    -- Set up metatable to inherit methods from World
    setmetatable(world, { __index = World })
    
    return world
end

-- Create world boundaries and add them to physics
function World:createBoundaries(physics)
    local boundaries = {}
    
    -- Ground plane
    boundaries.ground = {
        x = 0,
        y = self.height - self.groundHeight,
        width = self.width,
        height = self.groundHeight,
        vx = 0, vy = 0,
        type = "ground",
        isStatic = true,
        onGround = false  -- Not itself on ground
    }
    
    -- Left boundary wall
    boundaries.leftWall = {
        x = 0,
        y = 0,
        width = 10,           -- 10px thick wall
        height = self.height,
        vx = 0, vy = 0,
        type = "wall",
        isStatic = true,
        onGround = false
    }
    
    -- Right boundary wall
    boundaries.rightWall = {
        x = self.width - 10,   -- Positioned at right edge
        y = 0,
        width = 10,           -- 10px thick wall
        height = self.height,
        vx = 0, vy = 0,
        type = "wall",
        isStatic = true,
        onGround = false
    }
    
    -- Register boundaries with physics system
    physics:addBody(boundaries.ground)
    physics:addBody(boundaries.leftWall)
    physics:addBody(boundaries.rightWall)
    
    -- Store boundaries
    self.boundaries = boundaries
    
    return boundaries
end

-- Generate platforms in the world
function World:generatePlatforms(physics, count)
    local platforms = {}
    count = count or 5  -- Default number of platforms
    
    for i = 1, count do
        local width = math.random(100, 200)
        local x = math.random(100, self.width - width - 100)
        local y = math.random(200, self.height - 300)
        
        local platform = {
            x = x,
            y = y,
            width = width,
            height = 20,
            vx = 0, vy = 0,
            type = "platform",
            isStatic = true,
            onGround = false
        }
        
        physics:addBody(platform)
        table.insert(platforms, platform)
    end
    
    return platforms
end

-- Draw world elements
function World:draw()
    -- Draw sky background
    love.graphics.setColor(0.2, 0.3, 0.5) -- Sky blue
    love.graphics.rectangle("fill", 0, 0, self.width, self.height)
    
    -- Draw ground plane
    love.graphics.setColor(0.3, 0.6, 0.3) -- Grass green
    love.graphics.rectangle(
        "fill", 
        0, 
        self.height - self.groundHeight, 
        self.width, 
        self.groundHeight
    )
    
    -- Restore default color
    love.graphics.setColor(1, 1, 1, 1)
end

return World
