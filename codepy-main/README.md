# MathBlat - Multiplayer Math Puzzle Game

A fast-paced multiplayer math competition game built with Godot 4.5 GDScript. Test your arithmetic skills against AI or real players in a sleek space-themed interface.

## Features

- **Single-Player Mode**: Challenge an AI opponent with 70% accuracy
- **Local Multiplayer**: Play with friends on the same machine (via Host/Join)
- **Network Multiplayer**: Connect over LAN with proper ENet synchronization
- **3 Difficulty Levels**:
  - Easy (1-10, 10 points per correct)
  - Medium (1-50, 20 points per correct)
  - Hard (1-100, 30 points per correct)
- **15-Second Countdown**: Solve math problems within tight time constraints
- **Visual Polish**:
  - Smooth button hover animations (1.1x scale)
  - Elastic score pop-in animations
  - Screen shake on wrong answers
  - Particle effects for correct answers
- **Audio Feedback**:
  - Procedural "ding" sound for correct answers
  - Procedural "buzz" sound for wrong answers
- **Pause Menu**: Press ESC to pause/resume
- **High Score Persistence**: Scores automatically save to user directory
- **Win Condition**: First to 100 points wins and displays victory screen

## Quick Start

### Prerequisites
- Godot 4.5 or later
- Linux, Windows, or macOS

### Installation

```bash
# Clone or download project
cd /path/to/MathBlat

# Open in Godot 4.5
godot --path .
```

### Playing Single-Player

1. Launch the game
2. Main Menu → **Single-Player**
3. Choose difficulty: Easy / Medium / Hard
4. Answer math problems (+ - * /) before time runs out
5. First to 100 points wins!

### Playing Local Multiplayer

**Host (Player 1):**
1. Main Menu → **Host**
2. Choose difficulty
3. Wait for opponent to join

**Client (Player 2):**
1. Main Menu → **Join**
2. Enter Host IP (or "localhost" for same machine)
3. Choose same difficulty
4. Game starts when both players ready

### Network Multiplayer (LAN)

```
Player A (192.168.1.100):
  Main Menu → Host → Difficulty → Wait

Player B (192.168.1.101):
  Main Menu → Join → IP: 192.168.1.100 → Difficulty
```

Find your LAN IP:
```bash
# Linux/macOS
ifconfig | grep "inet "

# Windows
ipconfig | findstr "IPv4 Address"
```

## Project Structure

```
MathBlat/
├── scenes/
│   ├── main_menu.tscn          # Entry point with Host/Join UI
│   ├── difficulty_menu.tscn    # Difficulty selection (Easy/Medium/Hard)
│   ├── game_scene.tscn         # Main gameplay with UI and effects
│   ├── game.tscn               # Legacy (unused)
│   ├── single_player.tscn      # Legacy (unused)
│   └── victory_screen.tscn     # Victory display and high score
├── scripts/
│   ├── main_menu.gd            # Network setup (ENet host/join)
│   ├── difficulty_menu.gd      # Difficulty selection logic
│   ├── game_scene.gd           # Core game loop (239 lines)
│   ├── game_manager.gd         # Global state, problem generation
│   ├── game.gd                 # Legacy (unused)
│   ├── single_player.gd        # Legacy (unused)
│   ├── victory_screen.gd       # Victory logic and high score display
│   └── high_score_manager.gd   # Persistent high score storage
├── project.godot               # Project configuration (window 800x600)
├── export_presets.cfg          # Export settings for all platforms
├── EXPORT_CHECKLIST.md         # Comprehensive export/deployment guide
├── POLISH_FEATURES.md          # Animation and audio implementation details
└── README.md                   # This file
```

## Game Mechanics

### Problem Generation
- Host generates random math problem
- 4 answer options (1 correct, 3 wrong)
- Operations: + - * / with proper integer division
- Synced to all clients via RPC

### Scoring
- Correct answer: 10 × (difficulty + 1) points
  - Easy: +10 points
  - Medium: +20 points
  - Hard: +30 points
- Wrong answer: +0 points
- First to 100 points: Victory screen + high score save

### Timing
- 15 seconds per problem
- Countdown timer visible to all players
- Problems auto-advance on timeout

### Multiplayer Sync
- Host authority: Only host generates problems
- ENet RPC: `_sync_problem()` and `_sync_answer()` methods
- Reliable UDP: All game state synced to clients
- Disconnect handling: Error dialog if player disconnects

## Controls

### Keyboard/Mouse (Desktop)
- **Mouse Click**: Select answer button
- **ESC**: Toggle pause menu
- **Resume Button**: Unpause game
- **Quit Button**: Return to main menu

### Touch (Mobile)
- **Tap Button**: Select answer
- **Hold ESC equivalent**: Pause (device-specific)

## High Scores

High scores are automatically saved in:

```
Windows: C:\Users\[User]\AppData\Roaming\Godot\app_userdata\mathblat_highscores.json
Linux:   ~/.local/share/godot/app_userdata/mathblat_highscores.json
macOS:   ~/Library/Application\ Support/Godot/app_userdata/mathblat_highscores.json
Web:     Browser localStorage/IndexedDB
```

**Data Format (JSON):**
```json
[
  {"name":"Player","score":1250,"difficulty":"Hard","date":"2024-01-15 14:32"},
  {"name":"Player","score":980,"difficulty":"Medium","date":"2024-01-14 19:45"}
]
```

## Exporting

### Desktop (Windows/Linux/macOS)
```bash
godot --headless --export-release "Windows Desktop" build/MathBlat.exe
godot --headless --export-release "Linux/X11" build/MathBlat.x86_64
godot --headless --export-release "macOS" build/MathBlat.dmg
```

### Mobile (Android/iOS)
Requires platform SDKs and signing certificates. See [EXPORT_CHECKLIST.md](EXPORT_CHECKLIST.md) for detailed setup.

```bash
godot --headless --export-release "Android" build/MathBlat.apk
godot --headless --export-release "iOS" build/MathBlat.ipa
```

### Web (HTML5)
```bash
godot --headless --export-release "Web (HTML5)" build/index.html
```
Deploy `build/` folder to web server or [itch.io](https://itch.io).

## Troubleshooting

### Multiplayer Not Connecting
- Verify both machines on same network: `ping [other-ip]`
- Check port 12345 not blocked: `netstat -an | grep 12345`
- Try "localhost" for same-machine testing
- Restart Godot if port conflicts occur

### High Scores Not Saving
- Verify `HighScoreManager` autoload in `project.godot`
- Check user:// directory has write permissions
- Inspect JSON in `user://mathblat_highscores.json`

### Audio Issues
- Ensure audio drivers installed (ALSA/PulseAudio on Linux)
- Check system volume unmuted
- Verify AudioStreamPlayer nodes in game_scene.tscn

### Performance Issues
- Reduce particle count in game_scene.gd: `$CorrectParticles.amount = 20`
- Disable screen shake: Comment out `_shake_screen()` call
- Verify 60 FPS (desktop) / 30 FPS (mobile) with Engine.get_physics_frames()

## Development Notes

### Architecture
- **GameManager** (autoload): Global problem generation, difficulty state
- **HighScoreManager** (autoload): Persistent score storage via user://
- **main_menu.gd**: ENet server/client setup with multiplayer signals
- **game_scene.gd**: Core game loop with animations, audio, RPC sync

### Key Technologies
- **ENet**: High-level multiplayer using `ENetMultiplayerPeer`
- **Tween**: Animation system for smooth effects
- **AudioStreamGenerator**: Procedural audio for ding/buzz sounds
- **Particle2D**: Visual effects for correct answers

### Code Quality
- Consistent indentation (tabs)
- Clear function names and comments
- Proper RPC decorators: `@rpc("authority", "call_local", "reliable")`
- Signal connections in `_ready()` functions
- Graceful disconnect handling

## Performance Specs

| Platform | Target FPS | CPU | GPU |
|----------|-----------|-----|-----|
| Desktop  | 60        | <15% | <20% |
| Android  | 30        | <25% | <30% |
| iOS      | 30        | <25% | <30% |
| Web      | 60        | <20% | <25% |

## Known Limitations

- **AI Opponent**: 70% accuracy (intentional design for single-player balance)
- **Relay Server**: Not integrated; use LAN or port forwarding for internet play
- **Name Entry**: Victory screen defaults to "Player" (enhancement for future)
- **Localization**: English only in current build

## Future Enhancements

- [ ] Name entry on victory screen before high score save
- [ ] Relay service integration for internet play without port forwarding
- [ ] Leaderboard server (optional cloud sync)
- [ ] Additional math operations (exponents, roots)
- [ ] Sound effects library (external .ogg files)
- [ ] Multiple game modes (team play, endless, survival)
- [ ] Localization (Spanish, French, etc.)

## License

This project is open source. Modify and distribute freely.

## Credits

- **Engine**: [Godot 4.5](https://godotengine.org/)
- **Language**: GDScript
- **Audio**: Procedurally generated in GDScript
- **Rendering**: Vulkan (forward+ renderer)

## Support & Feedback

For issues, suggestions, or contributions:
- Report bugs with reproduction steps
- Test multiplayer on various networks
- Suggest balance adjustments (difficulty scaling, scoring)
- Request platform-specific optimizations

**Enjoy the game! 🎮✨**
