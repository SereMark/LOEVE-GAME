local Physics = {
    world = nil,
    scale = 32, -- pixels per meter
    entities = {},
    collisionCallbacks = {},
    debugDraw = false
}

function Physics:init()
    Debug:log("Initializing Physics System")
    
    -- Create physics world
    self.world = love.physics.newWorld(0, Constants.PHYSICS.GRAVITY, true)
    
    -- Set contact callbacks
    self.world:setCallbacks(
        function(a, b, contact) self:beginContact(a, b, contact) end,
        function(a, b, contact) self:endContact(a, b, contact) end,
        function(a, b, contact) self:preSolve(a, b, contact) end,
        function(a, b, contact, ...) self:postSolve(a, b, contact, ...) end
    )
    
    -- Clear entity list
    self.entities = {}
    
    Debug:log("Physics System initialized")
end

function Physics:update(dt)
    -- Update physics world
    self.world:update(dt)
    
    -- Update physics-controlled entities
    for id, entity in pairs(self.entities) do
        -- Only update if entity has body and is active
        if entity.body and entity.body:isActive() then
            -- Update entity position based on physics body
            entity.x = entity.body:getX() * self.scale
            entity.y = entity.body:getY() * self.scale
            entity.rotation = entity.body:getAngle()
        end
    end
end

function Physics:draw()
    -- Debug drawing of physics bodies
    if not self.debugDraw then return end
    
    love.graphics.setColor(0, 1, 0, 0.5)
    
    for id, entity in pairs(self.entities) do
        if entity.body then
            -- Draw fixtures
            for _, fixture in ipairs(entity.fixtures) do
                local shape = fixture:getShape()
                local shapeType = shape:getType()
                
                if shapeType == "circle" then
                    local x, y = entity.body:getWorldPoint(shape:getPoint())
                    local radius = shape:getRadius() * self.scale
                    love.graphics.circle("line", x * self.scale, y * self.scale, radius)
                elseif shapeType == "polygon" then
                    local points = {entity.body:getWorldPoints(shape:getPoints())}
                    for i = 1, #points do
                        points[i] = points[i] * self.scale
                    end
                    love.graphics.polygon("line", points)
                elseif shapeType == "edge" then
                    local x1, y1, x2, y2 = entity.body:getWorldPoints(shape:getPoints())
                    love.graphics.line(x1 * self.scale, y1 * self.scale, x2 * self.scale, y2 * self.scale)
                elseif shapeType == "chain" then
                    local points = {entity.body:getWorldPoints(shape:getPoints())}
                    for i = 1, #points do
                        points[i] = points[i] * self.scale
                    end
                    love.graphics.line(points)
                end
            end
        end
    end
    
    love.graphics.setColor(1, 1, 1, 1)
end

function Physics:createBody(entity, bodyType)
    -- Default to dynamic body if not specified
    bodyType = bodyType or "dynamic"
    
    -- Create physics body
    local body = love.physics.newBody(
        self.world, 
        entity.x / self.scale, 
        entity.y / self.scale, 
        bodyType
    )
    
    -- Store body in entity
    entity.body = body
    entity.fixtures = {}
    entity.bodyType = bodyType
    
    -- Store reference to entity in the body's user data
    body:setUserData(entity)
    
    -- Add entity to physics list
    self.entities[entity.id] = entity
    
    return body
end

function Physics:createRectangleFixture(entity, width, height, options)
    if not entity.body then
        Debug:log("Cannot create fixture for entity without a body")
        return nil
    end
    
    -- Default options
    options = options or {}
    
    -- Scale dimensions to physics world
    width = width / self.scale
    height = height / self.scale
    
    -- Create shape
    local shape = love.physics.newRectangleShape(0, 0, width, height)
    
    -- Create fixture
    local fixture = love.physics.newFixture(entity.body, shape, options.density or 1)
    
    -- Set fixture properties
    fixture:setFriction(options.friction or Constants.PHYSICS.FRICTION)
    fixture:setRestitution(options.restitution or 0)
    fixture:setSensor(options.isSensor or false)
    fixture:setFilterData(
        options.category or 0x0001,
        options.mask or 0xFFFF,
        options.group or 0
    )
    
    -- Store fixture in entity
    table.insert(entity.fixtures, fixture)
    
    -- Store category name for easier collision handling
    if options.categoryName then
        fixture:setUserData({entity = entity, category = options.categoryName})
    else
        fixture:setUserData({entity = entity})
    end
    
    return fixture
end

function Physics:createCircleFixture(entity, radius, options)
    if not entity.body then
        Debug:log("Cannot create fixture for entity without a body")
        return nil
    end
    
    -- Default options
    options = options or {}
    
    -- Scale dimensions to physics world
    radius = radius / self.scale
    
    -- Create shape
    local shape = love.physics.newCircleShape(0, 0, radius)
    
    -- Create fixture
    local fixture = love.physics.newFixture(entity.body, shape, options.density or 1)
    
    -- Set fixture properties
    fixture:setFriction(options.friction or Constants.PHYSICS.FRICTION)
    fixture:setRestitution(options.restitution or 0)
    fixture:setSensor(options.isSensor or false)
    fixture:setFilterData(
        options.category or 0x0001,
        options.mask or 0xFFFF,
        options.group or 0
    )
    
    -- Store fixture in entity
    table.insert(entity.fixtures, fixture)
    
    -- Store category name for easier collision handling
    if options.categoryName then
        fixture:setUserData({entity = entity, category = options.categoryName})
    else
        fixture:setUserData({entity = entity})
    end
    
    return fixture
end

function Physics:createPolygonFixture(entity, vertices, options)
    if not entity.body then
        Debug:log("Cannot create fixture for entity without a body")
        return nil
    end
    
    -- Default options
    options = options or {}
    
    -- Scale vertices to physics world
    local scaledVertices = {}
    for i, v in ipairs(vertices) do
        scaledVertices[i] = v / self.scale
    end
    
    -- Create shape
    local shape = love.physics.newPolygonShape(unpack(scaledVertices))
    
    -- Create fixture
    local fixture = love.physics.newFixture(entity.body, shape, options.density or 1)
    
    -- Set fixture properties
    fixture:setFriction(options.friction or Constants.PHYSICS.FRICTION)
    fixture:setRestitution(options.restitution or 0)
    fixture:setSensor(options.isSensor or false)
    fixture:setFilterData(
        options.category or 0x0001,
        options.mask or 0xFFFF,
        options.group or 0
    )
    
    -- Store fixture in entity
    table.insert(entity.fixtures, fixture)
    
    -- Store category name for easier collision handling
    if options.categoryName then
        fixture:setUserData({entity = entity, category = options.categoryName})
    else
        fixture:setUserData({entity = entity})
    end
    
    return fixture
end

function Physics:removeEntity(entity)
    if entity and entity.body then
        entity.body:destroy()
        entity.body = nil
        entity.fixtures = {}
        self.entities[entity.id] = nil
    end
end

function Physics:applyForce(entity, fx, fy)
    if entity and entity.body then
        entity.body:applyForce(fx, fy)
    end
end

function Physics:applyLinearImpulse(entity, ix, iy)
    if entity and entity.body then
        entity.body:applyLinearImpulse(ix, iy)
    end
end

function Physics:setLinearVelocity(entity, vx, vy)
    if entity and entity.body then
        entity.body:setLinearVelocity(vx, vy)
    end
end

function Physics:getLinearVelocity(entity)
    if entity and entity.body then
        return entity.body:getLinearVelocity()
    end
    return 0, 0
end

function Physics:setPosition(entity, x, y)
    if entity and entity.body then
        entity.body:setPosition(x / self.scale, y / self.scale)
        entity.x = x
        entity.y = y
    end
end

function Physics:setAngle(entity, angle)
    if entity and entity.body then
        entity.body:setAngle(angle)
        entity.rotation = angle
    end
end

function Physics:beginContact(fixture1, fixture2, contact)
    local userData1 = fixture1:getUserData()
    local userData2 = fixture2:getUserData()
    
    -- Get entities from fixtures
    local entity1 = userData1 and userData1.entity
    local entity2 = userData2 and userData2.entity
    
    -- Skip if either entity is missing
    if not entity1 or not entity2 then return end
    
    -- Get collision categories
    local category1 = userData1.category
    local category2 = userData2.category
    
    -- Call collision handlers if registered
    local collisionId1 = category1 and category2 and (category1 .. "-" .. category2)
    local collisionId2 = category1 and category2 and (category2 .. "-" .. category1)
    
    if collisionId1 and self.collisionCallbacks[collisionId1] then
        self.collisionCallbacks[collisionId1](entity1, entity2, contact)
    end
    
    if collisionId2 and self.collisionCallbacks[collisionId2] then
        self.collisionCallbacks[collisionId2](entity2, entity1, contact)
    end
    
    -- Call entity collision methods if they exist
    if entity1.onCollision then
        entity1:onCollision(entity2, contact)
    end
    
    if entity2.onCollision then
        entity2:onCollision(entity1, contact)
    end
end

function Physics:endContact(fixture1, fixture2, contact)
    local userData1 = fixture1:getUserData()
    local userData2 = fixture2:getUserData()
    
    -- Get entities from fixtures
    local entity1 = userData1 and userData1.entity
    local entity2 = userData2 and userData2.entity
    
    -- Skip if either entity is missing
    if not entity1 or not entity2 then return end
    
    -- Call entity collision end methods if they exist
    if entity1.onCollisionEnd then
        entity1:onCollisionEnd(entity2, contact)
    end
    
    if entity2.onCollisionEnd then
        entity2:onCollisionEnd(entity1, contact)
    end
end

function Physics:preSolve(fixture1, fixture2, contact)
    -- Pre-solve collision
end

function Physics:postSolve(fixture1, fixture2, contact, normalImpulse, tangentImpulse)
    -- Post-solve collision
end

function Physics:registerCollisionHandler(category1, category2, callback)
    local collisionId = category1 .. "-" .. category2
    self.collisionCallbacks[collisionId] = callback
end

function Physics:toggleDebugDraw()
    self.debugDraw = not self.debugDraw
    return self.debugDraw
end

function Physics:queryArea(x, y, width, height)
    -- Convert to physics scale
    x = x / self.scale
    y = y / self.scale
    width = width / self.scale
    height = height / self.scale
    
    local entities = {}
    
    -- Create a query callback
    local callback = function(fixture)
        local userData = fixture:getUserData()
        if userData and userData.entity then
            table.insert(entities, userData.entity)
        end
        return true -- continue the query
    end
    
    -- Query fixtures in the area
    self.world:queryBoundingBox(x, y, x + width, y + height, callback)
    
    return entities
end

return Physics