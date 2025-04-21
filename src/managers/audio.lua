local Audio = {
    currentMusic = nil,
    sounds = {},
    musicVolume = 0.5,
    sfxVolume = 0.7,
    muted = false
}

function Audio:init()
    Debug:log("Initializing Audio Manager")
    
    -- Load settings
    local settings = SaveLoad:loadSettings()
    if settings and settings.audio then
        self.musicVolume = settings.audio.musicVolume or Constants.AUDIO.MUSIC_VOLUME
        self.sfxVolume = settings.audio.sfxVolume or Constants.AUDIO.SFX_VOLUME
        self.muted = settings.audio.muted or false
    else
        self.musicVolume = Constants.AUDIO.MUSIC_VOLUME
        self.sfxVolume = Constants.AUDIO.SFX_VOLUME
    end
    
    -- Apply volume settings
    love.audio.setVolume(self.muted and 0 or 1)
    
    Debug:log("Audio Manager initialized")
end

function Audio:update(dt)
    -- Update sound instances
    for i = #self.sounds, 1, -1 do
        local sound = self.sounds[i]
        
        -- Update fade
        if sound.fading then
            sound.fadeTimer = sound.fadeTimer + dt
            local progress = math.min(1, sound.fadeTimer / sound.fadeDuration)
            
            if sound.fadeType == "out" then
                sound.source:setVolume((1 - progress) * sound.originalVolume)
                if progress >= 1 then
                    sound.source:stop()
                    table.remove(self.sounds, i)
                end
            elseif sound.fadeType == "in" then
                sound.source:setVolume(progress * sound.targetVolume)
                if progress >= 1 then
                    sound.fading = false
                end
            end
        end
        
        -- Remove stopped sounds
        if not sound.source:isPlaying() and not sound.fading then
            table.remove(self.sounds, i)
        end
    end
end

function Audio:playSound(name, volume, pitch)
    if self.muted then return nil end
    
    local source = Assets:getSound(name)
    if not source then return nil end
    
    -- Set volume and pitch
    volume = volume or 1
    pitch = pitch or 1
    source:setVolume(volume * self.sfxVolume)
    source:setPitch(pitch)
    
    -- Play the sound
    source:play()
    
    -- Add to active sounds list
    local sound = {
        source = source,
        name = name,
        originalVolume = volume * self.sfxVolume,
        fading = false
    }
    table.insert(self.sounds, sound)
    
    return sound
end

function Audio:playMusic(name, volume, fade)
    if self.currentMusic and self.currentMusic.name == name then
        -- Already playing this music
        return
    end
    
    -- Stop current music with fade out if requested
    if self.currentMusic then
        if fade then
            self:fadeOut(self.currentMusic, Constants.AUDIO.FADE_DURATION)
        else
            self.currentMusic.source:stop()
        end
    end
    
    -- Get new music
    local source = Assets:getMusic(name)
    if not source then return end
    
    -- Set volume
    volume = volume or 1
    source:setVolume(self.muted and 0 or (volume * self.musicVolume))
    
    -- Create music object
    self.currentMusic = {
        source = source,
        name = name,
        originalVolume = volume * self.musicVolume,
        fading = false
    }
    
    -- Start playing
    if fade then
        source:setVolume(0)
        source:play()
        self:fadeIn(self.currentMusic, Constants.AUDIO.FADE_DURATION)
    else
        source:play()
    end
end

function Audio:stopMusic(fade)
    if not self.currentMusic then return end
    
    if fade then
        self:fadeOut(self.currentMusic, Constants.AUDIO.FADE_DURATION)
    else
        self.currentMusic.source:stop()
        self.currentMusic = nil
    end
end

function Audio:pauseMusic()
    if self.currentMusic then
        self.currentMusic.source:pause()
    end
end

function Audio:resumeMusic()
    if self.currentMusic then
        self.currentMusic.source:play()
    end
end

function Audio:fadeOut(sound, duration)
    if not sound then return end
    
    sound.fading = true
    sound.fadeType = "out"
    sound.fadeTimer = 0
    sound.fadeDuration = duration or Constants.AUDIO.FADE_DURATION
    sound.originalVolume = sound.source:getVolume()
end

function Audio:fadeIn(sound, duration)
    if not sound then return end
    
    sound.fading = true
    sound.fadeType = "in"
    sound.fadeTimer = 0
    sound.fadeDuration = duration or Constants.AUDIO.FADE_DURATION
    sound.targetVolume = sound.originalVolume
    sound.source:setVolume(0)
end

function Audio:setMusicVolume(volume)
    self.musicVolume = Helpers.clamp(volume, 0, 1)
    
    if self.currentMusic then
        self.currentMusic.source:setVolume(self.muted and 0 or self.musicVolume)
    end
    
    -- Save settings
    SaveLoad:saveSettings({
        audio = {
            musicVolume = self.musicVolume,
            sfxVolume = self.sfxVolume,
            muted = self.muted
        }
    })
end

function Audio:setSFXVolume(volume)
    self.sfxVolume = Helpers.clamp(volume, 0, 1)
    
    -- Update all playing sound effects
    for _, sound in ipairs(self.sounds) do
        if sound ~= self.currentMusic then
            sound.source:setVolume(self.muted and 0 or (sound.originalVolume * self.sfxVolume / sound.originalSFXVolume))
            sound.originalSFXVolume = self.sfxVolume
        end
    end
    
    -- Save settings
    SaveLoad:saveSettings({
        audio = {
            musicVolume = self.musicVolume,
            sfxVolume = self.sfxVolume,
            muted = self.muted
        }
    })
end

function Audio:toggleMute()
    self.muted = not self.muted
    love.audio.setVolume(self.muted and 0 or 1)
    
    -- Save settings
    SaveLoad:saveSettings({
        audio = {
            musicVolume = self.musicVolume,
            sfxVolume = self.sfxVolume,
            muted = self.muted
        }
    })
    
    return self.muted
end

function Audio:isMuted()
    return self.muted
end

function Audio:stopAll()
    love.audio.stop()
    self.sounds = {}
    self.currentMusic = nil
end

return Audio