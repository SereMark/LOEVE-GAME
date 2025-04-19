<div align="center">

<img src="https://love2d.org/w/images/f/f5/love-logo-0.10.png" width="300" alt="LÖVE Logo">

[![LÖVE Version](https://img.shields.io/badge/L%C3%96VE-11.4%2B-FF6EC7.svg)](https://love2d.org/)
[![License](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)
[![Status](https://img.shields.io/badge/Status-In_Development-yellow.svg)]()

**An exciting new game being developed with LÖVE2D**

[About](#-about) • 
[Features](#-planned-features) • 
[Installation](#-installation) • 
[Controls](#-controls) • 
[Structure](#-project-structure) • 
[License](#-license)

</div>

## 📋 About

Welcome to our upcoming game project! We're creating an exciting new gaming experience using the LÖVE2D engine. While the specific game concept is still taking shape, we've built a solid foundation with state management, player controls, and debug tools to help us realize our creative vision.

Stay tuned as we develop this project further and reveal more details about the gameplay, story, and features!

## 🌟 Planned Features

- **🎭 Engaging Gameplay** - Unique mechanics and challenging objectives
- **🎨 Beautiful Visuals** - Distinctive art style and fluid animations
- **🎵 Immersive Audio** - Original soundtrack and sound effects
- **📈 Progression System** - Level up, unlock abilities, and discover new content
- **🏆 Achievements** - Complete challenges and earn rewards

## 🚀 Installation

### Prerequisites

- [LÖVE](https://love2d.org/) 11.4 or newer

### How to Play

```bash
# Clone the repository
git clone https://github.com/SereMark/LOEVE-GAME.git
cd LOEVE-GAME

# Run with LÖVE
love .
```

## 🎮 Controls

### Development Controls
| Key | Action |
|-----|--------|
| F1 | Toggle debug overlay |
| F5 | Restart game |
| F11 | Toggle fullscreen |

### Current Test Controls
| Key | Action |
|-----|--------|
| WASD / Arrow Keys | Move player |
| Space | Change player color |
| Escape | Pause game |
| M | Return to menu |

*Note: Controls may change as the game develops*

## 📁 Project Structure

```
root
│   conf.lua                # LÖVE configuration
│   LICENSE                 # License file
│   main.lua                # Main entry point
│   README.md               # This file
│   
├───.vscode
│       launch.json         # VSCode configuration
│       
├───assets
│   ├───fonts               # Game fonts
│   ├───images              # Sprites and graphics
│   ├───music               # Background music
│   └───sounds              # Sound effects
│
├───libs
│       class.lua           # OOP implementation
│
└───src
    │   constants.lua       # Game settings and constants
    │
    ├───entities
    │       entity.lua      # Base entity class
    │       player.lua      # Player implementation
    │
    ├───states
    │       gamestate.lua   # State manager
    │       menustate.lua   # Menu state
    │       playstate.lua   # Play state
    │       state.lua       # Base state class
    │
    └───utils
            debug.lua       # Debug utilities
            helpers.lua     # Helper functions
```

## 🎯 Current Status

This project is in active development. We are currently:

- Building core game mechanics
- Designing the game world
- Implementing the state management system
- Creating player character controls
- Setting up debugging tools

## 👥 Developers

- **Sere Gergő Márk** - *Game Design & Development*
- **Sere Bálint** - *Game Design & Development*

## 📜 License

This game is proprietary software and is protected under a custom license. See the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgements

- [LÖVE](https://love2d.org/) development team
- All playtesters and supporters

---

<div align="center">
  <p>Made with ❤️ and <a href="https://love2d.org/">LÖVE</a></p>
  <p>© 2025 Sere Gergő Márk & Sere Bálint. All Rights Reserved.</p>
</div>