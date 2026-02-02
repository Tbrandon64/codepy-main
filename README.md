# 🚀 Math Blast

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)
[![Godot 4.6](https://img.shields.io/badge/Godot-4.6-blue.svg)](https://godotengine.org)
[![GitHub Stars](https://img.shields.io/github/stars/Tbrandon64/codepy-main)](../../stargazers)
[![Download on itch.io](https://img.shields.io/badge/Download-itch.io-blue.svg)](https://itch.io/mathblast)
[![Release Ready](https://img.shields.io/badge/Status-Release%20Ready-green.svg)]()

> **Fast-paced multiplayer math puzzle game** • Solo, local co-op, or network play • No ads • 100% free

A competitive math competition game built with Godot 4.6. Test your arithmetic skills, build combos, climb leaderboards, and compete with friends—locally or over the network.

**[📥 Download](#installation) • [🎮 Play Online](https://itch.io/mathblast) • [📖 Documentation](#documentation) • [☕ Support](#support-math-blast) • [🐛 Issues](../../issues)**

---

## 🎉 Release Status

✅ **MathBlat is now RELEASE READY!**

- **UI Fixed**: All buttons and text are now visible with proper styling
- **Cross-Platform**: Configured for Windows, Linux, and Web exports
- **Build System**: Automated build script (`build_mathblast.bat`) ready
- **Python Backup**: Fallback systems ensure reliability
- **Testing**: All scenes compile and run without errors

**Latest Release**: [View on GitHub](../../releases)

---

## ✨ Features

### 🎮 Gameplay
- **Single-Player Mode**: Challenge AI with 70% accuracy
- **Local Multiplayer**: Play with friends on same machine
- **Network Multiplayer**: Connect over LAN (Windows, Linux, Mac)
- **3 Difficulty Levels**:
  - Easy (1-10, 10 pts/correct)
  - Medium (1-50, 20 pts/correct)
  - Hard (1-100, 30 pts/correct)
- **15-Second Rounds**: High-stakes speed math
- **Combo System**: Build 5x multipliers with consecutive correct answers
- **Power-ups**: Double Score, Freeze Time, Shield

### 🎨 Polish
- Smooth animations (1.1x button scale, elastic score pops)
- Screen shake on wrong answers
- Particle effects for correct answers
- Procedural audio (ding/buzz sounds)
- High score persistence

### ♿ Accessibility
- **High Contrast Mode** with custom color schemes
- **Text-to-Speech** (multiple languages)
- **Colorblind Modes** (Deuteranopia, Protanopia, Tritanopia)
- **Screen Reader Support**
- **Dyslexia-Friendly Font** option
- **Keyboard Navigation** (full support)
- **Motion Sensitivity** controls (reduces animations)
- **Captions** for all audio

### 🏆 Content
- **Achievement System**: 10+ unlockable badges
- **Player Profiles**: Custom names, stats, win rates
- **Daily Challenges**: 20 unique problem sets rotating daily
- **Teacher Mode**: Classroom management, progress tracking
- **Adventure Levels**: 15-level campaign with progressive difficulty

### 🎯 Reliability
- **Zero-Crash Policy**: Graceful error handling
- **Offline Support**: Core game works without internet
- **Cross-Platform**: Windows, Linux, macOS, Android, iOS

---

## 🚀 Quick Start

### Prerequisites
- **Godot 4.6+** (free, open-source)
- **Download**: [godotengine.org](https://godotengine.org)

### Installation

**Option 1: Download Pre-Built (Easiest)**
```bash
# Download from itch.io
# https://itch.io/mathblast

# Extract and run
./MathBlast.exe  # Windows
./MathBlast.x86_64  # Linux
./MathBlast.app  # macOS
```

**Option 2: Clone & Run from Source**
```bash
# Clone repo
git clone https://github.com/Tbrandon64/codepy-main.git
cd codepy-main

# Open in Godot 4.6+
godot --path codepy-main

# Press F5 to play
```

---

## 🎮 How to Play

### Single Player
1. Select "Single Player" from main menu
2. Choose difficulty
3. Solve math problems as fast as you can
4. First to 100 points wins!

### Local Multiplayer
1. Select "Host" to create a game
2. Share the IP address with friends
3. Friends click "Join" and enter the IP
4. Race to 100 points!

### Network Multiplayer
1. Same as local multiplayer
2. Works over LAN (local network only for security)
3. Supports up to 4 players per game

---

## � Project Structure

```
math-blast/
├── 📂 .github/                          # GitHub configuration
│   ├── 📂 ISSUE_TEMPLATE/
│   │   ├── bug_report.yml              # Bug report form
│   │   └── feature_request.yml         # Feature request form
│   └── PULL_REQUEST_TEMPLATE.md        # PR guidelines
│
├── 📂 scenes/                           # Game scenes (Godot)
│   ├── main_menu.tscn                  # Main menu with Host/Join
│   ├── difficulty_menu.tscn            # Difficulty selection
│   ├── game_scene.tscn                 # Core gameplay
│   ├── victory_screen.tscn             # Victory screen
│   ├── adventure_map.tscn              # Adventure mode
│   ├── teacher_portal.tscn             # Teacher mode
│   └── ...
│
├── 📂 scripts/                          # GDScript files
│   ├── game_manager.gd                 # Problem generation & state
│   ├── game_scene.gd                   # Core game loop
│   ├── main_menu.gd                    # Network setup (ENet)
│   ├── high_score_manager.gd           # High score storage
│   ├── achievement_system.gd           # Achievements & leveling
│   ├── badge_manager.gd                # Badge system
│   ├── player_profile_manager.gd       # Player profiles
│   ├── daily_challenge_manager.gd      # Daily challenges
│   ├── accessibility_manager.gd        # Accessibility features
│   ├── audio_manager.gd                # Audio & sound effects
│   ├── localization_manager.gd         # Multi-language support
│   ├── config_file_handler.gd          # Settings persistence
│   ├── gameplay_enhancement_system.gd  # Combos & power-ups
│   ├── victory_screen_enhanced.gd      # Victory features
│   ├── main_menu_enhanced.gd           # Mute & hard mode
│   ├── multiplayer_lobby_enhanced.gd   # Lobby features
│   ├── thumbnail_generator.gd          # Promo image creator
│   └── splash_screen.gd                # Intro logo
│
├── 📂 python_backup/                    # Python fallback system
│   ├── __init__.py
│   ├── score_manager.py
│   ├── teacher_mode.py
│   ├── problem_generator.py
│   ├── backup_system.py
│   └── config_manager.py
│
├── 📂 tools/                            # Utility scripts
│   ├── PackageMathBlast.bat            # Windows packaging tool
│   └── ...
│
├── 📂 docs/                             # Documentation (optional)
│   ├── ACCESSIBILITY.md                # Accessibility guide
│   ├── TEACHER_MODE.md                 # Teacher mode guide
│   ├── MULTIPLAYER.md                  # Multiplayer setup
│   ├── EXPORT.md                       # Export instructions
│   └── ARCHIVE/                        # Archived documentation
│
├── 📄 README.md                         # ← YOU ARE HERE
├── 📄 CONTRIBUTING.md                  # How to contribute
├── 📄 CODE_OF_CONDUCT.md               # Community guidelines
├── 📄 LICENSE                          # MIT License
├── 📄 CODE_STYLE_GUIDE.md              # Coding standards
├── 📄 GITHUB_SETUP.md                  # GitHub setup guide
├── 📄 GITHUB_ORGANIZATION_CHECKLIST.md # Setup checklist
├── 📄 EXPORT_CHECKLIST.md              # Export procedures
│
├── project.godot                       # Godot project file
├── export_presets.cfg                  # Platform export config
└── .gitignore                          # Git ignore rules
```

### Key Directories Explained

| Directory | Purpose |
|-----------|---------|
| **scripts/** | All game logic (GDScript) - core gameplay, AI, multiplayer, accessibility |
| **scenes/** | UI and game scenes (Godot scene files) - main menu, game, victory screen |
| **python_backup/** | Fallback Python system for fail-safe architecture |
| **tools/** | Utility scripts for packaging and deployment |
| **.github/** | GitHub configuration - issue templates, PR templates |
| **docs/** | Additional documentation - guides and archived files |

### Important Files

| File | Purpose |
|------|---------|
| `project.godot` | Godot engine configuration and autoloads |
| `export_presets.cfg` | Build settings for all platforms (Windows, Linux, macOS, Android, iOS, Web) |
| `CONTRIBUTING.md` | How to contribute to the project |
| `CODE_OF_CONDUCT.md` | Community values and standards |
| `LICENSE` | MIT License (free to use and modify) |

---

## �📚 Documentation

- [**Accessibility Guide**](docs/ACCESSIBILITY.md) - Detailed accessibility features
- [**Teacher Mode Guide**](docs/TEACHER_MODE.md) - Classroom setup & management
- [**Multiplayer Guide**](docs/MULTIPLAYER.md) - Network setup & troubleshooting
- [**Code Style Guide**](CODE_STYLE_GUIDE.md) - For developers
- [**Contributing**](CONTRIBUTING.md) - How to contribute
- [**Export Guide**](docs/EXPORT.md) - Build for different platforms

---

## ⚙️ Configuration

### Game Settings
- Difficulty selection
- Volume controls (Master, Music, SFX)
- Display options (fullscreen, resolution)
- Accessibility settings (contrast, font size, etc.)

### Save Data Location
```
Windows: %APPDATA%/Godot/app_userdata/math_blast_*
Linux:   ~/.local/share/godot/app_userdata/math_blast_*
macOS:   ~/Library/Application Support/Godot/math_blast_*
```

### Troubleshooting
- **Game won't start**: Update Godot to 4.5+
- **Multiplayer not working**: Ensure firewall allows game
- **Performance issues**: Lower graphics settings
- **Audio not playing**: Check system volume, unmute game

See [Troubleshooting Wiki](../../wiki/Troubleshooting) for more.

---

## 🏗️ Building from Source

### Export Windows
```bash
godot --headless --export-release "Windows Desktop" build/MathBlast.exe
```

### Export Linux
```bash
godot --headless --export-release "Linux/X11" build/MathBlast.x86_64
```

### Export macOS
```bash
godot --headless --export-release "macOS" build/MathBlast.dmg
```

### Export Web (Itch.io)
```bash
godot --headless --export-release "Web" build/
```

See [EXPORT_CHECKLIST.md](EXPORT_CHECKLIST.md) for full instructions.

---

## 🌟 New in v1.0

✅ Accessibility system (8+ features)
✅ Badge & achievement system  
✅ Daily challenges (20 problems)
✅ Player profiles with custom names
✅ Hard mode with 3x speed
✅ Victory screen with confetti
✅ Mute toggle on main menu
✅ LAN lobby enhancements
✅ Splash screen with MB logo

---

## 📦 Tech Stack

- **Engine**: [Godot 4.5](https://godotengine.org/) (MIT License)
- **Language**: GDScript 2.0
- **Audio**: Procedurally generated in GDScript
- **Networking**: ENet (built into Godot)
- **Rendering**: Vulkan (forward+ renderer)

---

## 🤝 Contributing

Found a bug? Have an idea? **We'd love your help!**

See [CONTRIBUTING.md](CONTRIBUTING.md) for:
- How to report bugs
- How to suggest features
- How to submit code changes
- Development setup

**Quick Links:**
- [Open Issues](../../issues)
- [Create Issue](../../issues/new)
- [Submit PR](../../pulls)
- [Code of Conduct](CODE_OF_CONDUCT.md)

---

## 💡 Support Math Blast ❤️

Love the game? Consider supporting development:

### 🎁 Donate
[![Ko-fi](https://img.shields.io/badge/Ko--fi-F16061?style=for-the-badge&logo=ko-fi&logoColor=white)](https://ko-fi.com/mathblast)

Your support helps us:
- 🎨 Create new levels and content
- ♿ Improve accessibility
- 🚀 Add multiplayer features
- 📱 Expand to more platforms

*All donations are appreciated but never required to play!*

### 📢 Spread the Word
- Star this repo ⭐
- Share with friends
- Post on social media
- Review on itch.io

---

## 📄 License

This project is licensed under the **MIT License** - see [LICENSE](LICENSE) file for details.

Free to use, modify, and distribute for personal and commercial projects.

---

## 🎮 Community

- **GitHub Issues**: [Report bugs & request features](../../issues)
- **GitHub Discussions**: [Ask questions & share ideas](../../discussions)
- **Ko-fi**: [Support development & chat](https://ko-fi.com/mathblast)
- **Itch.io**: [Download & leave review](https://itch.io/mathblast)

---

## 👥 Credits

**Development**: Thomas Brandon  
**Engine**: [Godot 4.5](https://godotengine.org/)  
**Community**: [Contributors](../../graphs/contributors)

---

## 🔗 Links

| Link | URL |
|------|-----|
| Download | https://itch.io/mathblast |
| Website | https://mathblast.dev |
| Discord | https://discord.gg/mathblast |
| Twitter | https://twitter.com/mathblastgame |
| Ko-fi | https://ko-fi.com/mathblast |

---

**Enjoy Math Blast! 🚀✨**

*Made with ❤️ in Godot 4.5*
