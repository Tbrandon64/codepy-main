# MathBlat Game Development Guide

## Architecture Overview

MathBlat is a Godot 4.6 multiplayer math puzzle game with a feature-flag driven architecture. The core systems are organized as autoload singletons:

- **GameManager**: Central problem generation, scoring, and difficulty management
- **FeatureConfig**: Runtime feature toggles (teacher portal, energy system, adventure mode)
- **AchievementSystem**: Player progress tracking and unlockables
- **AudioManager/LocalizationManager**: Cross-platform media handling

All major systems use lazy-loading and optional dependencies. The game includes Python backup implementations for critical functionality.

## Key Patterns

### Feature Flags & Conditional UI
Use `FeatureConfig` for optional features. Hide/show UI elements conditionally:

```gdscript
# In main_menu.gd - conditional button visibility
if FeatureConfig.adventure_mode_enabled:
    get_node("VBoxContainer/AdventureBtn").show()
else:
    get_node("VBoxContainer/AdventureBtn").hide()
```

### Autoload Communication
Access global systems via autoload references. Never instantiate managers manually:

```gdscript
# Correct - use autoload
GameManager.generate_problem()
AchievementSystem.unlock_achievement("first_win")

# Incorrect - don't create instances
var gm = GameManager.new()
```

### UI Styling in Scenes
Define button backgrounds directly in `.tscn` files using `StyleBoxFlat` sub-resources, not script-only styling. Godot 4.6 requires scene-defined styles for reliable rendering.

### Python Backup Integration
Critical systems have Python fallbacks in `python_backup/`. Use when Godot implementations fail:

```python
from python_backup.backup_system import BackupSystem
backup = BackupSystem()
problem = backup.generate_problem("MEDIUM")
```

## Development Workflow

### Building & Running
- **Editor**: `godot --path codepy-main` or open `project.godot`
- **Export**: Run `build_mathblast.bat` for Windows/Linux/Web builds
- **Test Scene**: `godot --path codepy-main --scene scenes/main_menu.tscn`

### Debugging
- Use Godot's built-in debugger for GDScript
- Python systems: Run `python python_backup/backup_system.py` for testing
- Check `user://` directory for config/score files

### File Organization
- `scenes/`: Godot scene files (.tscn)
- `scripts/`: GDScript implementations
- `python_backup/`: Python fallback systems
- `assets/`: Fonts, audio, resources

## Common Gotchas

- Always check `FeatureConfig` before accessing optional systems
- Use `get_node_or_null()` for conditional UI elements
- Scene files must define StyleBoxFlat backgrounds for button visibility
- Python backup systems require manual initialization
- Window settings in `project.godot` affect UI rendering
- Font resources must be properly configured (arial_bold.tres uses system Arial)

## Testing Python Components
```bash
cd codepy-main/python_backup
python backup_system.py  # Manual testing
```

## Release Checklist
- ✅ UI elements visible with colored buttons
- ✅ Font resources properly configured
- ✅ Export presets configured for Windows/Linux/Web
- ✅ Python backup systems functional
- ✅ All scenes compile without errors
- ✅ Build script ready for multi-platform export</content>
<parameter name="filePath">c:\Users\tb586\Documents\codepy-main\.github\copilot-instructions.md