# Quick Setup Guide - Adventure Mode & Teacher Portal

## Installation Steps

### Step 1: File Structure
Ensure all new files are in place:

```
codepy-main/
├── scripts/
│   ├── energy_system.gd          [NEW]
│   ├── adventure_manager.gd      [NEW]
│   ├── feature_config.gd         [NEW]
│   ├── adventure_map.gd          [NEW]
│   ├── adventure_level.gd        [NEW]
│   ├── teacher_portal.gd         [NEW]
│   ├── main_menu.gd              [UPDATED]
│   ├── game.gd                   [UPDATED]
│   └── single_player.gd          [UPDATED]
├── scenes/
│   ├── adventure_map.tscn        [NEW]
│   ├── adventure_level.tscn      [NEW]
│   ├── teacher_portal.tscn       [NEW]
│   └── main_menu.tscn            [UPDATED]
└── project.godot                 [UPDATED]
```

### Step 2: Update project.godot

Open `project.godot` and verify the autoload section includes:

```ini
[autoload]
GameManager="*res://scripts/game_manager.gd"
HighScoreManager="*res://scripts/high_score_manager.gd"
EnergySystem="*res://scripts/energy_system.gd"
AdventureManager="*res://scripts/adventure_manager.gd"
FeatureConfig="*res://scripts/feature_config.gd"
```

### Step 3: Update Main Menu Scene (Optional UI Update)

If you want the new buttons to appear visually on the main menu:

1. Open `scenes/main_menu.tscn` in Godot
2. In the VBoxContainer, add two new Button nodes:
   - Name: `AdventureBtn`, Text: "🎮 Adventure Mode" (Purple color)
   - Name: `TeacherPortalBtn`, Text: "🎓 Teacher Portal" (Dark Red color, optional)
3. The `main_menu.gd` script will automatically connect these buttons

### Step 4: Reload Godot

1. Close the Godot editor
2. Reopen your project
3. Verify no errors in the Output panel

---

## Feature Configuration

### Configuration File Location

Settings are stored in: `user://gameconfig.json`

### Default Settings

By default, only the energy system and adventure mode are enabled. The teacher portal is **disabled**.

To check current settings, add this to any script and run it:

```gdscript
print("Energy System:", FeatureConfig.energy_system_enabled)
print("Adventure Mode:", FeatureConfig.adventure_mode_enabled)
print("Teacher Portal:", FeatureConfig.teacher_portal_enabled)
print("Multiplayer:", FeatureConfig.multiplayer_enabled)
```

### Enabling Features

#### Enable Teacher Portal (For Educational Use)

Add this code to your startup script or `_ready()` function:

```gdscript
func _ready():
	FeatureConfig.set_teacher_portal_enabled(true)
	# Now the teacher portal will appear in the main menu
```

Or manually edit `user://gameconfig.json`:
```json
{
	"teacher_portal_enabled": true,
	...
}
```

#### Disable Adventure Mode

```gdscript
FeatureConfig.set_adventure_mode_enabled(false)
```

#### Disable Energy System

```gdscript
FeatureConfig.set_energy_system_enabled(false)
```

---

## Testing the Installation

### Test 1: Energy System

1. Run the game
2. Open DevTools Console (F12)
3. Enter: `EnergySystem.get_current_energy()`
4. Should return: `100` (starting energy)

### Test 2: Adventure Mode

1. Run the game
2. Click **Adventure Mode** button
3. Should see a map with 5 dungeons
4. Click a dungeon to play

### Test 3: Teacher Portal (If Enabled)

1. Run the game
2. Click **Teacher Portal** button (should appear if enabled)
3. Login with any email@domain.com
4. Should see dashboard with Classes/Settings/Analytics tabs

### Test 4: Energy Consumption

1. Play a single-player game
2. Check `EnergySystem.get_current_energy()` again
3. Should be reduced by the cost (15 for single player)

---

## Common Issues & Solutions

### Issue: Adventure Mode button doesn't appear

**Solution**:
1. Make sure `adventure_map.tscn` exists in the scenes folder
2. Check that `FeatureConfig.adventure_mode_enabled` is `true`
3. Re-run `_setup_button_styles()` in main_menu.gd

### Issue: "Can't find EnergySystem" error

**Solution**:
1. Verify `energy_system.gd` is in the scripts folder
2. Check project.godot has `EnergySystem="*res://scripts/energy_system.gd"` in autoload
3. Restart the Godot editor

### Issue: Teacher Portal button not appearing

**Solution**:
1. Make sure `teacher_portal_enabled` is set to `true` in FeatureConfig
2. Add the TeacherPortalBtn to main_menu.tscn if not already there
3. The button will automatically appear after re-enabling

### Issue: Energy not regenerating

**Solution**:
1. Make sure the game is running (not paused)
2. Energy regenerates 10 points per minute
3. Check that `user://energy_data.json` exists
4. Verify no errors in Output panel

### Issue: Adventure dungeons all locked

**Solution**:
1. Make sure you have at least 10 energy (dungeons start at 10+ required)
2. Complete the first dungeon to unlock the next
3. Check `AdventureManager.can_enter_dungeon(dungeon_id)` returns true

---

## Production Deployment

### For Commercial/Public Release

If shipping without educational features:

```gdscript
# In main startup code
FeatureConfig.set_teacher_portal_enabled(false)
FeatureConfig.set_adventure_mode_enabled(true)
FeatureConfig.set_energy_system_enabled(true)
```

### For Educational Edition

If shipping as an educational tool:

```gdscript
# In main startup code
FeatureConfig.set_teacher_portal_enabled(true)
FeatureConfig.set_adventure_mode_enabled(true)
FeatureConfig.set_energy_system_enabled(true)
```

### Export Settings

The game can be exported to all platforms with these features enabled:

- ✅ Web (HTML5)
- ✅ Windows
- ✅ macOS
- ✅ Linux
- ✅ Android
- ✅ iOS

All data persists correctly across platforms thanks to the `user://` directory.

---

## Next Steps

1. ✅ Install all files
2. ✅ Update project.godot
3. ✅ Test the features
4. ✅ Configure your desired settings
5. ✅ Export and deploy

For more detailed information, see [ADVENTURE_MODE_GUIDE.md](ADVENTURE_MODE_GUIDE.md)
