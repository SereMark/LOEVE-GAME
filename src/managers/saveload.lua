local SaveLoad = {
    saveData = nil,
    settings = nil
}

function SaveLoad:init()
    Debug:log("Initializing Save/Load System")
    
    -- Ensure save directory exists
    love.filesystem.createDirectory("saves")
    
    -- Load settings
    self:loadSettings()
    
    Debug:log("Save/Load System initialized")
end

function SaveLoad:saveGame(slot)
    -- Create a save data table with all necessary game state
    local data = {
        version = Constants.GAME.VERSION,
        timestamp = os.time(),
        player = {
            -- Player-specific data
            health = GameState.current.player and GameState.current.player.health or 100,
            position = GameState.current.player and {x = GameState.current.player.x, y = GameState.current.player.y} or {x = 0, y = 0},
            inventory = GameState.current.player and GameState.current.player.inventory or {}
        },
        gameStats = {
            -- Game statistics
            score = GameState.current.score or 0,
            level = GameState.current.level or 1,
            playTime = GameState.current.playTime or 0
        },
        worldState = {
            -- World state data
            currentMap = GameState.current.map and GameState.current.map.name or "start",
            visitedAreas = GameState.current.visitedAreas or {},
            unlockedItems = GameState.current.unlockedItems or {}
        }
    }
    
    -- Convert to JSON
    local success, content = pcall(function() return require("libs.json").encode(data) end)
    
    if success then
        -- Save to file
        local filename = "saves/save_" .. (slot or "quicksave") .. ".json"
        local success, message = love.filesystem.write(filename, content)
        
        if success then
            Debug:log("Game saved to " .. filename)
            return true
        else
            Debug:log("Failed to save game: " .. (message or "Unknown error"))
            return false, message
        end
    else
        Debug:log("Failed to encode save data: " .. tostring(content))
        return false, "Failed to encode save data"
    end
end

function SaveLoad:loadGame(slot)
    local filename = "saves/save_" .. (slot or "quicksave") .. ".json"
    
    -- Check if save file exists
    if not love.filesystem.getInfo(filename) then
        Debug:log("Save file not found: " .. filename)
        return false, "Save file not found"
    end
    
    -- Read file
    local content, size = love.filesystem.read(filename)
    if not content then
        Debug:log("Failed to read save file: " .. filename)
        return false, "Failed to read save file"
    end
    
    -- Parse JSON
    local success, data = pcall(function() return require("libs.json").decode(content) end)
    
    if success then
        -- Version check
        if data.version ~= Constants.GAME.VERSION then
            Debug:log("Warning: Save file version mismatch. Expected " .. Constants.GAME.VERSION .. ", got " .. (data.version or "unknown"))
            -- Continue loading but warn the player
        end
        
        -- Store save data
        self.saveData = data
        
        -- Apply save data to game state
        if GameState.current and GameState.current.name == "Play" then
            -- Apply directly to current state
            self:applyGameData(data)
        else
            -- Switch to play state and apply data there
            GameState:switch("Play", data)
        end
        
        Debug:log("Game loaded from " .. filename)
        return true
    else
        Debug:log("Failed to parse save file: " .. tostring(data))
        return false, "Failed to parse save file"
    end
end

function SaveLoad:applyGameData(data)
    -- Apply loaded data to the current game state
    local state = GameState.current
    
    -- Apply player data
    if state.player and data.player then
        state.player.health = data.player.health
        state.player.x = data.player.position.x
        state.player.y = data.player.position.y
        state.player.inventory = data.player.inventory
    end
    
    -- Apply game stats
    state.score = data.gameStats.score
    state.level = data.gameStats.level
    state.playTime = data.gameStats.playTime
    
    -- Apply world state
    state.visitedAreas = data.worldState.visitedAreas
    state.unlockedItems = data.worldState.unlockedItems
    
    -- Load map if different
    if state.map and state.map.name ~= data.worldState.currentMap then
        state:loadMap(data.worldState.currentMap)
    end
end

function SaveLoad:saveSettings(newSettings)
    -- Merge new settings with existing ones
    if newSettings then
        if not self.settings then
            self.settings = {}
        end
        
        for category, values in pairs(newSettings) do
            if not self.settings[category] then
                self.settings[category] = {}
            end
            
            for key, value in pairs(values) do
                self.settings[category][key] = value
            end
        end
    end
    
    -- Add current version
    if self.settings then
        self.settings.version = Constants.GAME.VERSION
    end
    
    -- Convert to JSON
    local success, content = pcall(function() return require("libs.json").encode(self.settings or {}) end)
    
    if success then
        -- Save to file
        local success, message = love.filesystem.write(Constants.GAME.SETTINGS_FILE, content)
        
        if success then
            Debug:log("Settings saved")
            return true
        else
            Debug:log("Failed to save settings: " .. (message or "Unknown error"))
            return false, message
        end
    else
        Debug:log("Failed to encode settings: " .. tostring(content))
        return false, "Failed to encode settings"
    end
end

function SaveLoad:loadSettings()
    -- Check if settings file exists
    if not love.filesystem.getInfo(Constants.GAME.SETTINGS_FILE) then
        -- Create default settings
        self.settings = {
            version = Constants.GAME.VERSION,
            video = {
                fullscreen = false,
                vsync = true,
                resolution = {width = 1280, height = 720}
            },
            audio = {
                musicVolume = Constants.AUDIO.MUSIC_VOLUME,
                sfxVolume = Constants.AUDIO.SFX_VOLUME,
                muted = false
            },
            gameplay = {
                difficulty = "normal",
                showTutorials = true
            }
        }
        
        -- Save default settings
        self:saveSettings()
        
        return self.settings
    end
    
    -- Read file
    local content, size = love.filesystem.read(Constants.GAME.SETTINGS_FILE)
    if not content then
        Debug:log("Failed to read settings file")
        return nil
    end
    
    -- Parse JSON
    local success, data = pcall(function() return require("libs.json").decode(content) end)
    
    if success then
        self.settings = data
        Debug:log("Settings loaded")
        return self.settings
    else
        Debug:log("Failed to parse settings file: " .. tostring(data))
        return nil
    end
end

function SaveLoad:getSaveSlots()
    local saves = {}
    local files = love.filesystem.getDirectoryItems("saves")
    
    for _, file in ipairs(files) do
        if file:match("^save_.+%.json$") then
            local slot = file:match("^save_(.+)%.json$")
            local info = love.filesystem.getInfo("saves/" .. file)
            
            -- Try to read basic info
            local content = love.filesystem.read("saves/" .. file)
            local saveInfo = {
                slot = slot,
                filename = file,
                modtime = info.modtime
            }
            
            if content then
                local success, data = pcall(function() return require("libs.json").decode(content) end)
                if success then
                    saveInfo.version = data.version
                    saveInfo.timestamp = data.timestamp
                    saveInfo.level = data.gameStats and data.gameStats.level
                    saveInfo.playTime = data.gameStats and data.gameStats.playTime
                end
            end
            
            table.insert(saves, saveInfo)
        end
    end
    
    -- Sort by modification time (newest first)
    table.sort(saves, function(a, b) return a.modtime > b.modtime end)
    
    return saves
end

function SaveLoad:deleteSave(slot)
    local filename = "saves/save_" .. slot .. ".json"
    
    -- Check if save file exists
    if not love.filesystem.getInfo(filename) then
        Debug:log("Save file not found: " .. filename)
        return false, "Save file not found"
    end
    
    -- Delete file
    local success, message = love.filesystem.remove(filename)
    
    if success then
        Debug:log("Save file deleted: " .. filename)
        return true
    else
        Debug:log("Failed to delete save file: " .. (message or "Unknown error"))
        return false, message
    end
end

return SaveLoad