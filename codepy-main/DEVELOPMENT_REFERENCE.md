# MathBlat Development Quick Reference

## Project Overview

**Game**: Multiplayer math competition puzzle
**Engine**: Godot 4.5 GDScript
**Network**: ENet multiplayer with RPC
**Window**: 800x600 pixels
**Theme**: Black space background with cyan/colored UI
**Platform Support**: Windows, Linux, macOS, Android, iOS, Web

---

## Quick Commands

### Launch Game
```bash
cd /home/Thomas/codepy
godot
```

### Export Commands
```bash
# Windows
godot --headless --export-release "Windows Desktop" build/MathBlat.exe

# Linux
godot --headless --export-release "Linux/X11" build/MathBlat.x86_64

# macOS
godot --headless --export-release "macOS" build/MathBlat.dmg

# Android
godot --headless --export-release "Android" build/MathBlat.apk

# iOS
godot --headless --export-release "iOS" build/MathBlat.ipa

# Web
godot --headless --export-release "Web (HTML5)" build/index.html
```

### Multiplayer Testing
```bash
# Terminal 1: Host
godot & Main Menu → Host → Easy

# Terminal 2: Client
godot & Main Menu → Join → localhost → Easy
```

---

## File Reference

### Core Scripts

| File | Purpose | Key Functions |
|------|---------|---|
| `game_manager.gd` | Global state & problem generation | `generate_problem()`, `check_answer()`, `set_difficulty()` |
| `high_score_manager.gd` | Persistent score storage | `save_score()`, `load_high_scores()`, `is_high_score()` |
| `main_menu.gd` | ENet networking setup | `_on_host_pressed()`, `_on_join_pressed()` |
| `difficulty_menu.gd` | Difficulty selection | `_start_game(difficulty)` |
| `game_scene.gd` | Core game loop (239 lines) | `_display_next_problem()`, `_on_option_pressed()`, `_input()` |
| `victory_screen.gd` | Victory display & high score | `_show_high_score_info()`, `_on_restart_pressed()` |

### Scene Files

| File | Purpose | Key Nodes |
|------|---------|---|
| `main_menu.tscn` | Entry point | Host/Join/Single-Player/Quit buttons |
| `difficulty_menu.tscn` | Difficulty selection | Easy/Medium/Hard buttons |
| `game_scene.tscn` | Gameplay UI | Problem label, timer, 4 answer buttons, pause menu |
| `victory_screen.tscn` | Victory display | Score labels, high score indicator, buttons |

### Configuration

| File | Purpose | Key Settings |
|------|---------|---|
| `project.godot` | Project config | Window 800x600, Vulkan renderer, autoloads |
| `export_presets.cfg` | Export settings | 6 presets (Windows, Linux, macOS, Android, iOS, Web) |

### Documentation

| File | Purpose | Contents |
|------|---------|---|
| `README.md` | Main documentation | Features, quick start, controls, troubleshooting |
| `EXPORT_CHECKLIST.md` | Export guide | Platform-specific export steps & QA checklist |
| `MULTIPLAYER_TESTING.md` | Testing guide | Network test scenarios, debugging, relay setup |
| `POLISH_FEATURES.md` | Implementation details | Animations, audio, particles, effects |

---

## Game Flow

```
Main Menu
├── Single-Player
│   └── Difficulty Menu
│       └── Game Scene (vs AI)
│           └── Victory Screen
├── Host
│   └── Difficulty Menu
│       └── Game Scene (waiting for client)
│           └── Victory Screen
├── Join
│   └── IP/Port Input
│       └── Difficulty Menu
│           └── Game Scene (connected to host)
│               └── Victory Screen
└── Quit (exit)
```

---

## Architecture Patterns

### Global Managers (Autoload)
```gdscript
# Access anywhere in code
GameManager.score
GameManager.generate_problem()

HighScoreManager.save_score()
HighScoreManager.get_high_scores()
```

### RPC Method Pattern
```gdscript
@rpc("authority", "call_local", "reliable")
func _sync_problem(num1: int, operation: String, num2: int, options: Array) -> void:
    # Only host authority can call
    # Called locally on host + synced to clients
    # Reliable delivery (no packet loss)
    pass
```

### Signal Connection Pattern
```gdscript
func _ready() -> void:
    button.pressed.connect(_on_button_pressed)
    timer.timeout.connect(_on_timer_timeout)
    multiplayer.peer_connected.connect(_on_peer_connected)
```

### Tween Animation Pattern
```gdscript
var tween = create_tween()
tween.set_trans(Tween.TRANS_CUBIC)
tween.set_ease(Tween.EASE_OUT)
tween.tween_property(button, "scale", Vector2(1.1, 1.1), 0.2)
```

---

## Key Variables & State

### GameManager
```gdscript
var current_difficulty: Difficulty = Difficulty.EASY
var score: int = 0
var opponent_score: int = 0
var current_problem: MathProblem
```

### Game Scene
```gdscript
var player_score: int = 0
var opponent_score: int = 0
var time_remaining: int = 15
var is_paused: bool = false
var connection_lost: bool = false
var is_multiplayer: bool = false
var is_host: bool = false
```

### Math Problem
```gdscript
class MathProblem:
    var num1: int
    var num2: int
    var operation: String  # "+", "-", "*", "/"
    var correct_answer: int
    var options: Array[int]  # 4 choices
```

---

## Debugging Tips

### Console Output
```gdscript
# Trace function calls
print("DEBUG: function called with %s" % variable)

# Monitor RPC calls
print("RPC: _sync_answer(%d, %d)" % [option_idx, score])

# Check network state
print("Is multiplayer: ", multiplayer.is_server())
print("Connected peers: ", multiplayer.get_peers())
```

### Breakpoints in Godot
```gdscript
# Godot 4.5 has built-in debugger
# Press F5 or use debugger in bottom panel
# Set breakpoints by clicking line numbers
```

### Network Debugging
```bash
# Monitor port 12345
netstat -an | grep 12345
sudo tcpdump port 12345 -v

# Test connectivity
ping 192.168.1.100
nc -zv 192.168.1.100 12345
```

---

## Common Modifications

### Change Winning Score
File: `game_scene.gd`
```gdscript
var win_score: int = 100  # Change this value
```

### Adjust Difficulty Multiplier
File: `game_manager.gd`
```gdscript
func check_answer(option_index: int) -> bool:
    var points = 10 * (int(current_difficulty) + 1)  # Modify multiplier
    GameManager.score += points
```

### Change Countdown Time
File: `game_scene.gd`
```gdscript
var time_remaining: int = 15  # Change to desired seconds
$GameTimer.wait_time = 1.0  # Must match
```

### Modify AI Accuracy
File: `game_scene.gd`
```gdscript
func _get_ai_answer() -> int:
    if randf() < 0.7:  # Change 0.7 to adjust AI accuracy
        return problem.correct_answer
    else:
        return problem.options[randi() % 4]
```

### Customize Colors
File: Scene .tscn files
```
Button modulate = Color(R, G, B, A)  # 0.0-1.0 range
Label add_theme_color_override("font_color", Color.YELLOW)
```

### Change Window Size
File: `project.godot`
```ini
[display]
window/size/viewport_width=1024
window/size/viewport_height=768
```

---

## Performance Optimization

### Desktop Target (60 FPS)
- Keep particle count < 50
- Tween animations use EASE_OUT
- No physics bodies (2D only)

### Mobile Target (30 FPS)
- Reduce particle count to 20
- Disable screen shake on low-end devices
- Use simpler animations

**Monitor Performance**:
```gdscript
# In _process(delta)
var fps = 1.0 / delta
if int(fps) % 10 == 0:
    print("FPS: %.1f" % fps)
```

---

## Testing Checklist

### Before Each Build
- [ ] No syntax errors in any .gd files
- [ ] All scenes load without errors
- [ ] Main menu → all branches work (Single, Host, Join)
- [ ] Single-player: 1+ match completes
- [ ] Multiplayer: Host/client sync works
- [ ] High scores save after game exit

### Before Export
- [ ] All scenes connect to scripts correctly
- [ ] No missing resource warnings
- [ ] Project runs cleanly from `godot --path .`
- [ ] No compile errors: F5 debug launch successful

### Platform-Specific
- **Desktop**: Window size correct, Vulkan renders
- **Mobile**: Touch buttons responsive, high scores save
- **Web**: HTML loads, audio plays, responsive layout

---

## Network Troubleshooting Matrix

| Problem | Check | Fix |
|---------|-------|-----|
| Can't connect | Host running? | `godot` → Host → Easy |
| Timeout | Firewall? | `sudo ufw allow 12345/tcp` |
| No sync | RPC connected? | Check game_scene.tscn signals |
| Lag | Network latency? | Ping <100ms required |
| Disconnect | Network stable? | Move closer to router |

---

## Version Control

### Git Workflow
```bash
cd /home/Thomas/codepy
git add .
git commit -m "Add export configuration and high score system"
git tag -a v1.0.0 -m "Initial release"
git push origin main
```

### Branches
- `main`: Production-ready code
- `develop`: Active development
- `feature/relay-integration`: Feature branches

---

## Support Resources

- [Godot 4.5 Docs](https://docs.godotengine.org/en/stable/)
- [GDScript Reference](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/index.html)
- [ENet Multiplayer](https://docs.godotengine.org/en/stable/tutorials/networking/using_3d_characters/networking.html)
- [Export Documentation](https://docs.godotengine.org/en/stable/tutorials/export/index.html)

---

## Quick Contact Info

For bugs/features:
- File: Create issue with reproduction steps
- Test: Use MULTIPLAYER_TESTING.md scenarios
- Export: Follow EXPORT_CHECKLIST.md steps

**Last Updated**: 2024
**Maintained By**: Development Team
