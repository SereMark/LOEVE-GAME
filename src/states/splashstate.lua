local State = require("src.states.state")
local Constants = require("src.constants")
local GameState = require("src.states.gamestate")
local Debug = require("src.utils.debug")

local SplashState = State:new("Splash")

function SplashState:init()
    self.timer = 0
    self.duration = 3  -- Splash screen duration in seconds
    self.fadeInTime = 0.5
    self.fadeOutTime = 0.5
    self.logoScale = 0
    self.logoTargetScale = 1
    self.alpha = 0
    
    -- Create logo particle effect
    self.particles = love.graphics.newParticleSystem(ParticleSystem:createDefaultParticle(), 100)
    self.particles:setParticleLifetime(0.5, 1.5)
    self.particles:setEmissionRate(20)
    self.particles:setSizes(1, 2)
    self.particles:setColors(1, 1, 1, 1, 1, 1, 1, 0)
    self.particles:setLinearAcceleration(-20, -20, 20, 20)
    self.particles:setEmitterLifetime(-1)
    self.particles:start()
end

function SplashState:enter()
    Debug:log("Entered splash state")
    
    -- Play logo sound
    Audio:playSound("startup")
    
    -- Preload assets
    Assets:init()
    
    -- Start with logo animation
    self.timer = 0
    self.logoScale = 0
    self.alpha = 0
end

function SplashState:update(dt)
    -- Update timer
    self.timer = self.timer + dt
    
    -- Update logo animation
    if self.timer < self.fadeInTime then
        -- Fade in
        self.alpha = self.timer / self.fadeInTime
        self.logoScale = Helpers.lerp(0, self.logoTargetScale, self.timer / self.fadeInTime)
    elseif self.timer < self.duration - self.fadeOutTime then
        -- Fully visible
        self.alpha = 1
        self.logoScale = self.logoTargetScale
    else
        -- Fade out
        local fadeProgress = (self.timer - (self.duration - self.fadeOutTime)) / self.fadeOutTime
        self.alpha = 1 - fadeProgress
    end
    
    -- Update particles
    self.particles:update(dt)
    
    -- Switch to menu state when done
    if self.timer >= self.duration then
        GameState:switch("Menu")
    end
    
    -- Skip splash with any key or mouse button
    if love.keyboard.isDown("space") or love.keyboard.isDown("return") or love.mouse.isDown(1) then
        GameState:switch("Menu")
    end
end

function SplashState:draw()
    local width, height = love.graphics.getDimensions()
    
    -- Draw background
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.rectangle("fill", 0, 0, width, height)
    
    -- Draw logo
    love.graphics.setColor(1, 1, 1, self.alpha)
    
    -- Draw company/game logo
    local logoX = width / 2
    local logoY = height / 2
    
    -- If we have a logo image, draw it
    local logo = Assets.images["logo"]
    if logo then
        love.graphics.draw(
            logo,
            logoX,
            logoY,
            0,  -- rotation
            self.logoScale,
            self.logoScale,
            logo:getWidth() / 2,
            logo:getHeight() / 2
        )
    else
        -- Otherwise draw text
        love.graphics.setFont(Fonts.title)
        local text = Constants.GAME.TITLE
        local textWidth = Fonts.title:getWidth(text)
        love.graphics.print(text, logoX - textWidth / 2, logoY - Fonts.title:getHeight() / 2)
    end
    
    -- Draw particles
    love.graphics.draw(self.particles, logoX, logoY)
    
    -- Reset color
    love.graphics.setColor(1, 1, 1, 1)
end

function SplashState:keypressed(key)
    -- Skip splash with any key
    GameState:switch("Menu")
end

function SplashState:mousepressed(x, y, button)
    -- Skip splash with any mouse button
    GameState:switch("Menu")
end

SplashState:init()

return SplashState