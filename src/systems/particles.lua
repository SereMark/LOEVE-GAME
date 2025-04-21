local ParticleSystem = {
    systems = {},
    templates = {}
}

function ParticleSystem:init()
    Debug:log("Initializing Particle System")
    
    -- Create predefined particle templates
    self:createTemplates()
    
    Debug:log("Particle System initialized")
end

function ParticleSystem:createTemplates()
    -- Explosion particles
    self.templates.explosion = {
        image = "particle",
        buffer = Constants.PARTICLES.EXPLOSION_COUNT,
        config = {
            colors = {
                {1, 0.5, 0, 1},   -- Orange
                {1, 0.7, 0, 1},   -- Light orange
                {1, 0, 0, 1},     -- Red
                {0.6, 0.1, 0, 1}  -- Dark red
            },
            sizes = {2, 6},
            particleLifetime = {0.3, 0.8},
            emissionRate = 0,
            emitterLifetime = 0.1,
            speed = {100, 200},
            direction = 0,
            spread = math.pi * 2,
            linearDamping = 2,
            radialAcceleration = -40,
            sizeVariation = 1,
            rotationRange = {0, math.pi * 2},
            spinRange = {-10, 10}
        }
    }
    
    -- Spark particles
    self.templates.spark = {
        image = "particle",
        buffer = 100,
        config = {
            colors = {
                {1, 1, 0, 1},     -- Yellow
                {1, 0.6, 0, 1},   -- Orange
                {1, 0.3, 0, 0}    -- Red (fades out)
            },
            sizes = {1, 2},
            particleLifetime = {0.1, 0.5},
            emissionRate = 100,
            emitterLifetime = 0.1,
            speed = {80, 180},
            direction = -math.pi/2,  -- Up
            spread = math.pi/4,
            linearDamping = 1,
            sizeVariation = 0.5
        }
    }
    
    -- Smoke particles
    self.templates.smoke = {
        image = "particle",
        buffer = 200,
        config = {
            colors = {
                {0.3, 0.3, 0.3, 0.7},  -- Gray
                {0.4, 0.4, 0.4, 0.5},  -- Light gray
                {0.5, 0.5, 0.5, 0.3},  -- Lighter gray
                {0.6, 0.6, 0.6, 0}     -- White (fades out)
            },
            sizes = {5, 10},
            sizeVariation = 0.5,
            growthRate = 10,
            particleLifetime = {1, 2},
            emissionRate = 20,
            speed = {10, 30},
            direction = -math.pi/2,  -- Up
            spread = math.pi/6,
            linearDamping = 0.2,
            rotationRange = {0, math.pi * 2},
            spinRange = {-1, 1}
        }
    }
    
    -- Trail particles
    self.templates.trail = {
        image = "particle",
        buffer = 100,
        config = {
            colors = {
                {0.8, 0.8, 1, 0.8},    -- Light blue
                {0.4, 0.4, 1, 0.5},    -- Blue
                {0.2, 0.2, 0.8, 0}     -- Dark blue (fades out)
            },
            sizes = {2, 4},
            particleLifetime = {0.2, 0.5},
            emissionRate = Constants.PARTICLES.TRAIL_EMIT_RATE,
            emitterLifetime = -1,      -- Continuous
            speed = {5, 10},
            direction = math.pi/2,     -- Down
            spread = math.pi/6,
            linearDamping = 1,
            sizeVariation = 0.3
        }
    }
    
    -- Water splash particles
    self.templates.splash = {
        image = "particle",
        buffer = 100,
        config = {
            colors = {
                {0, 0.5, 1, 0.8},      -- Blue
                {0.2, 0.7, 1, 0.5},    -- Light blue
                {0.5, 0.8, 1, 0}       -- Very light blue (fades out)
            },
            sizes = {2, 4},
            particleLifetime = {0.5, 1.0},
            emissionRate = 50,
            emitterLifetime = 0.2,
            speed = {50, 150},
            direction = -math.pi/2,    -- Up
            spread = math.pi/2,
            linearDamping = 3,
            linearAcceleration = {0, 200},  -- Gravity
            sizeVariation = 0.5
        }
    }
    
    -- Collectible shine particles
    self.templates.shine = {
        image = "particle",
        buffer = 50,
        config = {
            colors = {
                {1, 1, 0.6, 0.8},      -- Light yellow
                {1, 1, 0.8, 0.5},      -- Very light yellow
                {1, 1, 1, 0}           -- White (fades out)
            },
            sizes = {1, 2},
            particleLifetime = {0.5, 1.0},
            emissionRate = 5,
            emitterLifetime = -1,      -- Continuous
            speed = {10, 20},
            direction = 0,
            spread = math.pi * 2,      -- All directions
            linearDamping = 0.5,
            sizeVariation = 0.3
        }
    }
    
    -- Hit impact particles
    self.templates.hit = {
        image = "particle",
        buffer = 30,
        config = {
            colors = {
                {1, 1, 1, 1},          -- White
                {0.9, 0.9, 0.9, 0.7},  -- Light gray
                {0.8, 0.8, 0.8, 0}     -- Gray (fades out)
            },
            sizes = {2, 5},
            particleLifetime = {0.1, 0.3},
            emissionRate = 0,
            emitterLifetime = 0.05,
            speed = {50, 150},
            direction = 0,
            spread = math.pi * 2,      -- All directions
            linearDamping = 5,
            sizeVariation = 0.5
        }
    }
end

function ParticleSystem:update(dt)
    -- Update all particle systems
    for i = #self.systems, 1, -1 do
        local system = self.systems[i]
        
        -- Update particle system
        system.ps:update(dt)
        
        -- Update position if following an entity
        if system.followEntity and system.followEntity.x then
            system.x = system.followEntity.x + (system.offsetX or 0)
            system.y = system.followEntity.y + (system.offsetY or 0)
        end
        
        -- Remove inactive systems
        if not system.ps:isActive() and system.autoRemove then
            table.remove(self.systems, i)
        end
    end
end

function ParticleSystem:draw()
    -- Draw all particle systems
    for _, system in ipairs(self.systems) do
        love.graphics.setColor(system.color or {1, 1, 1, 1})
        love.graphics.draw(system.ps, system.x, system.y)
    end
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

function ParticleSystem:createSystem(x, y, template, customConfig)
    local templateData = self.templates[template]
    if not templateData then
        Debug:log("Warning: Particle template '" .. template .. "' not found")
        return nil
    end
    
    -- Get image for particle
    local image = Assets:getImage(templateData.image) or self:createDefaultParticle()
    
    -- Create particle system
    local ps = love.graphics.newParticleSystem(image, templateData.buffer)
    
    -- Apply template configuration
    self:configureParticleSystem(ps, templateData.config)
    
    -- Apply custom configuration if provided
    if customConfig then
        self:configureParticleSystem(ps, customConfig)
    end
    
    -- Create system object
    local system = {
        ps = ps,
        x = x,
        y = y,
        template = template,
        autoRemove = true
    }
    
    -- Add to systems list
    table.insert(self.systems, system)
    
    return system
end

function ParticleSystem:configureParticleSystem(ps, config)
    -- Apply configuration to particle system
    if config.colors then
        if #config.colors == 1 then
            ps:setColors(unpack(config.colors[1]))
        else
            ps:setColors(unpack(config.colors))
        end
    end
    
    if config.sizes then
        if #config.sizes == 1 then
            ps:setSizes(config.sizes[1])
        else
            ps:setSizes(unpack(config.sizes))
        end
    end
    
    if config.particleLifetime then
        ps:setParticleLifetime(unpack(config.particleLifetime))
    end
    
    if config.emissionRate then
        ps:setEmissionRate(config.emissionRate)
    end
    
    if config.emitterLifetime then
        ps:setEmitterLifetime(config.emitterLifetime)
    end
    
    if config.speed then
        ps:setSpeed(unpack(config.speed))
    end
    
    if config.direction and config.spread then
        ps:setDirection(config.direction)
        ps:setSpread(config.spread)
    end
    
    if config.linearAcceleration then
        ps:setLinearAcceleration(unpack(config.linearAcceleration))
    end
    
    if config.radialAcceleration then
        ps:setRadialAcceleration(config.radialAcceleration)
    end
    
    if config.tangentialAcceleration then
        ps:setTangentialAcceleration(config.tangentialAcceleration)
    end
    
    if config.linearDamping then
        ps:setLinearDamping(config.linearDamping)
    end
    
    if config.sizeVariation then
        ps:setSizeVariation(config.sizeVariation)
    end
    
    if config.rotationRange then
        ps:setRotation(unpack(config.rotationRange))
    end
    
    if config.spinRange then
        ps:setSpin(unpack(config.spinRange))
    end
    
    if config.offset then
        ps:setOffset(unpack(config.offset))
    end
    
    if config.insertMode then
        ps:setInsertMode(config.insertMode)
    else
        ps:setInsertMode("random")
    end
    
    if config.areaSpread then
        ps:setAreaSpread(unpack(config.areaSpread))
    end
    
    -- Additional configurations
    if config.growthRate then
        ps:setSizeVariation(1)
        ps:setRelativeRotation(true)
    end
    
    if config.spread360 then
        ps:setDirection(0)
        ps:setSpread(math.pi * 2)
    end
    
    -- Emit particles immediately if burst
    if config.burst then
        ps:emit(config.burst)
    else
        -- Start the system
        ps:start()
    end
end

function ParticleSystem:createDefaultParticle()
    -- Create a simple circular particle image
    local size = 16
    local data = love.image.newImageData(size, size)
    
    -- Draw a circle
    for x = 0, size - 1 do
        for y = 0, size - 1 do
            local dx = x - size / 2
            local dy = y - size / 2
            local dist = math.sqrt(dx * dx + dy * dy)
            
            if dist < size / 2 then
                -- Soft gradient from center to edge
                local alpha = 1 - (dist / (size / 2))
                data:setPixel(x, y, 1, 1, 1, alpha)
            else
                data:setPixel(x, y, 0, 0, 0, 0)
            end
        end
    end
    
    return love.graphics.newImage(data)
end

function ParticleSystem:createExplosion(x, y, scale, color)
    local system = self:createSystem(x, y, "explosion")
    
    if system then
        -- Apply custom scale and color if provided
        if scale then
            system.ps:setSizes(system.ps:getSizes() * scale)
        end
        
        if color then
            system.color = color
        end
        
        -- Emit particles in a burst
        system.ps:emit(Constants.PARTICLES.EXPLOSION_COUNT)
    end
    
    return system
end

function ParticleSystem:createTrail(entity, offsetX, offsetY, color)
    local system = self:createSystem(entity.x, entity.y, "trail")
    
    if system then
        -- Set to follow entity
        system.followEntity = entity
        system.offsetX = offsetX or 0
        system.offsetY = offsetY or 0
        
        if color then
            system.color = color
        end
    end
    
    return system
end

function ParticleSystem:stopTrail(entity)
    -- Find and stop trails following this entity
    for _, system in ipairs(self.systems) do
        if system.followEntity == entity then
            system.followEntity = nil
            system.ps:stop()
        end
    end
end

function ParticleSystem:createSplash(x, y, intensity)
    local system = self:createSystem(x, y, "splash")
    
    if system and intensity then
        system.ps:setEmissionRate(system.ps:getEmissionRate() * intensity)
        system.ps:setSpeed(unpack({system.ps:getSpeed() * intensity}))
    end
    
    return system
end

function ParticleSystem:createHitEffect(x, y, direction)
    local system = self:createSystem(x, y, "hit")
    
    if system and direction then
        -- Orient the hit effect in the direction of impact
        system.ps:setDirection(direction)
        system.ps:setSpread(math.pi / 4)  -- Narrow spread
    end
    
    -- Emit particles in a burst
    system.ps:emit(30)
    
    return system
end

function ParticleSystem:clearAll()
    -- Remove all particle systems
    self.systems = {}
end

return ParticleSystem