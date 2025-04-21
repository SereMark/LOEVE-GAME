local Constants = {
    -- Game information
    GAME = {
        TITLE = "Untitled Adventure",
        VERSION = "0.1.0",
        SCALE = 3,
        DEBUG = true,
        SAVE_FILE = "savedata.json",
        SETTINGS_FILE = "settings.json",
    },
    
    -- Colors
    COLORS = {
        WHITE = {1, 1, 1, 1},
        BLACK = {0, 0, 0, 1},
        RED = {1, 0, 0, 1},
        GREEN = {0, 1, 0, 1},
        BLUE = {0, 0, 1, 1},
        YELLOW = {1, 1, 0, 1},
        CYAN = {0, 1, 1, 1},
        MAGENTA = {1, 0, 1, 1},
        ORANGE = {1, 0.5, 0, 1},
        PURPLE = {0.5, 0, 0.5, 1},
        GRAY = {0.5, 0.5, 0.5, 1},
        LIGHT_GRAY = {0.8, 0.8, 0.8, 1},
        DARK_GRAY = {0.2, 0.2, 0.2, 1},
        BACKGROUND = {0.05, 0.05, 0.1, 1},
        UI_BG = {0.1, 0.1, 0.2, 0.8},
        UI_BORDER = {0.3, 0.3, 0.5, 1},
        UI_HIGHLIGHT = {0.4, 0.4, 0.8, 1},
        PLAYER = {0.2, 0.8, 0.4, 1},
        ENEMY = {0.8, 0.2, 0.2, 1}
    },
    
    -- Player settings
    PLAYER = {
        SPEED = 200,
        SIZE = 32,
        MAX_HEALTH = 100,
        FIRE_RATE = 0.2,
        INVULNERABILITY_TIME = 1.5,
        ACCELERATION = 800,
        FRICTION = 400,
        DASH_POWER = 600,
        DASH_COOLDOWN = 1.0
    },
    
    -- Enemy settings
    ENEMY = {
        BASIC = {
            SPEED = 100,
            SIZE = 32,
            HEALTH = 30,
            DAMAGE = 10,
            SCORE = 100
        },
        FAST = {
            SPEED = 180,
            SIZE = 24,
            HEALTH = 15,
            DAMAGE = 5,
            SCORE = 150
        },
        TANK = {
            SPEED = 60,
            SIZE = 48,
            HEALTH = 80,
            DAMAGE = 20,
            SCORE = 200
        },
        BOSS = {
            SPEED = 80,
            SIZE = 96,
            HEALTH = 500,
            DAMAGE = 30,
            SCORE = 1000
        }
    },
    
    -- Projectile settings
    PROJECTILE = {
        PLAYER = {
            SPEED = 500,
            SIZE = 8,
            DAMAGE = 10,
            LIFETIME = 2
        },
        ENEMY = {
            SPEED = 300,
            SIZE = 8,
            DAMAGE = 5,
            LIFETIME = 3
        }
    },
    
    -- Collectible settings
    COLLECTIBLE = {
        HEALTH = {
            SIZE = 16,
            HEAL_AMOUNT = 20
        },
        POWERUP = {
            SIZE = 16,
            DURATION = 10
        },
        COIN = {
            SIZE = 16,
            VALUE = 10
        }
    },
    
    -- Physics settings
    PHYSICS = {
        GRAVITY = 800,
        FRICTION = 0.85,
        TILE_SIZE = 32
    },
    
    -- Camera settings
    CAMERA = {
        LERP_SPEED = 5,
        SHAKE_DECAY = 5,
        ZOOM_SPEED = 4
    },
    
    -- UI settings
    UI = {
        PADDING = 10,
        MARGIN = 5,
        BORDER_WIDTH = 2,
        BUTTON_HEIGHT = 50,
        TOOLTIP_DELAY = 0.5
    },
    
    -- Audio settings
    AUDIO = {
        MUSIC_VOLUME = 0.5,
        SFX_VOLUME = 0.7,
        FADE_DURATION = 1.0
    },
    
    -- Particle settings
    PARTICLES = {
        MAX_PARTICLES = 1000,
        EXPLOSION_COUNT = 50,
        TRAIL_EMIT_RATE = 20
    },
    
    -- Layer settings
    LAYERS = {
        BACKGROUND = 1,
        TERRAIN = 2,
        COLLECTIBLES = 3,
        ENEMIES = 4,
        PROJECTILES = 5,
        PLAYER = 6,
        EFFECTS = 7,
        UI = 8
    },
    
    -- Level settings
    LEVEL = {
        WIDTH = 50,
        HEIGHT = 30,
        ENEMY_SPAWN_RATE = 5,
        MAX_ENEMIES = 20
    }
}

return Constants