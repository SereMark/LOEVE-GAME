local Assets = {
    images = {},
    sounds = {},
    music = {},
    sprites = {},
    fonts = {},
    shaders = {}
}

function Assets:init()
    Debug:log("Initializing Asset Manager")
    
    -- Create asset directories if they don't exist
    love.filesystem.createDirectory("assets")
    love.filesystem.createDirectory("assets/images")
    love.filesystem.createDirectory("assets/sounds")
    love.filesystem.createDirectory("assets/music")
    love.filesystem.createDirectory("assets/fonts")
    love.filesystem.createDirectory("assets/shaders")
    
    -- Set default filter
    love.graphics.setDefaultFilter("nearest", "nearest")
    
    -- Load assets
    self:loadImages()
    self:loadSounds()
    self:loadMusic()
    self:loadShaders()
    
    Debug:log("Asset Manager initialized")
end

function Assets:loadImages()
    -- Load all images from the images directory
    local imageFiles = love.filesystem.getDirectoryItems("assets/images")
    for _, file in ipairs(imageFiles) do
        if file:match("%.png$") or file:match("%.jpg$") then
            local name = file:gsub("%.png$", ""):gsub("%.jpg$", "")
            self.images[name] = love.graphics.newImage("assets/images/" .. file)
            Debug:log("Loaded image: " .. file)
        end
    end
    
    -- Create placeholder image if no images exist
    if not next(self.images) then
        self.images["placeholder"] = self:createPlaceholderImage(32, 32)
        Debug:log("Created placeholder image")
    end
    
    -- Create sprite batches from loaded images
    self:createSprites()
end

function Assets:loadSounds()
    -- Load all sound effects from the sounds directory
    local soundFiles = love.filesystem.getDirectoryItems("assets/sounds")
    for _, file in ipairs(soundFiles) do
        if file:match("%.wav$") or file:match("%.ogg$") or file:match("%.mp3$") then
            local name = file:gsub("%.wav$", ""):gsub("%.ogg$", ""):gsub("%.mp3$", "")
            self.sounds[name] = love.audio.newSource("assets/sounds/" .. file, "static")
            Debug:log("Loaded sound: " .. file)
        end
    end
end

function Assets:loadMusic()
    -- Load all music from the music directory
    local musicFiles = love.filesystem.getDirectoryItems("assets/music")
    for _, file in ipairs(musicFiles) do
        if file:match("%.wav$") or file:match("%.ogg$") or file:match("%.mp3$") then
            local name = file:gsub("%.wav$", ""):gsub("%.ogg$", ""):gsub("%.mp3$", "")
            self.music[name] = love.audio.newSource("assets/music/" .. file, "stream")
            self.music[name]:setLooping(true)
            Debug:log("Loaded music: " .. file)
        end
    end
end

function Assets:loadShaders()
    -- Load all shaders from the shaders directory
    local shaderFiles = love.filesystem.getDirectoryItems("assets/shaders")
    for _, file in ipairs(shaderFiles) do
        if file:match("%.glsl$") or file:match("%.frag$") or file:match("%.vert$") then
            local name = file:gsub("%.glsl$", ""):gsub("%.frag$", ""):gsub("%.vert$", "")
            self.shaders[name] = love.graphics.newShader("assets/shaders/" .. file)
            Debug:log("Loaded shader: " .. file)
        end
    end
    
    -- Create default shaders if none exist
    if not next(self.shaders) then
        -- Create a simple grayscale shader
        local pixelCode = [[
            vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
                vec4 pixel = Texel(texture, texture_coords) * color;
                float average = (pixel.r + pixel.g + pixel.b) / 3.0;
                return vec4(average, average, average, pixel.a);
            }
        ]]
        self.shaders["grayscale"] = love.graphics.newShader(pixelCode)
        Debug:log("Created grayscale shader")
    end
end

function Assets:createSprites()
    -- Create sprite objects from image assets
    for name, image in pairs(self.images) do
        self.sprites[name] = love.graphics.newSpriteBatch(image)
    end
end

function Assets:createPlaceholderImage(width, height)
    -- Create a simple placeholder image with a checkerboard pattern
    local data = love.image.newImageData(width, height)
    
    for x = 0, width - 1 do
        for y = 0, height - 1 do
            local color
            if (x + y) % 2 == 0 then
                color = {1, 0, 1, 1}  -- Magenta
            else
                color = {0, 0, 0, 1}  -- Black
            end
            data:setPixel(x, y, color[1], color[2], color[3], color[4])
        end
    end
    
    return love.graphics.newImage(data)
end

function Assets:getImage(name)
    if self.images[name] then
        return self.images[name]
    else
        Debug:log("Warning: Image '" .. name .. "' not found, using placeholder")
        return self.images["placeholder"] or self:createPlaceholderImage(32, 32)
    end
end

function Assets:getSprite(name)
    if self.sprites[name] then
        return self.sprites[name]
    else
        Debug:log("Warning: Sprite '" .. name .. "' not found, using placeholder")
        return self.sprites["placeholder"] or love.graphics.newSpriteBatch(self:createPlaceholderImage(32, 32))
    end
end

function Assets:getSound(name)
    if self.sounds[name] then
        return self.sounds[name]:clone()
    else
        Debug:log("Warning: Sound '" .. name .. "' not found")
        return nil
    end
end

function Assets:getMusic(name)
    if self.music[name] then
        return self.music[name]
    else
        Debug:log("Warning: Music '" .. name .. "' not found")
        return nil
    end
end

function Assets:getShader(name)
    if self.shaders[name] then
        return self.shaders[name]
    else
        Debug:log("Warning: Shader '" .. name .. "' not found")
        return nil
    end
end

return Assets