# MathBlat - Adventure Mode & Teacher Portal Updates

## 🎮 New Features Added

This update introduces two major systems to MathBlat:

### 1. **Adventure Mode** 🗺️
A Minecraft Dungeons-style progression system where players navigate through procedurally generated dungeons.

#### Key Features:
- **Dungeon Map Navigation**: Minecraft Dungeons-inspired map with connected rooms
- **Progressive Difficulty**: Dungeons scale in difficulty as players progress
- **Energy-Based System**: Each dungeon requires energy to enter
- **Rewards & Experience**: Players earn experience, unlock new areas, and progress through adventure levels
- **Persistent Progression**: Adventure progress is automatically saved and can be resumed

#### How It Works:
1. Start from Main Menu → **Adventure Mode**
2. Select a dungeon from the map (unlocked dungeons are available)
3. Complete the dungeon by solving math problems correctly
4. Earn rewards: Energy + Experience Points
5. Unlock the next dungeon when current one is cleared
6. Advance to new maps after clearing all dungeons in current map

#### Energy System:
- **Starting Energy**: 100 units
- **Max Energy**: 100 units
- **Energy Regeneration**: 10 units per minute automatically
- **Energy Costs by Mode**:
  - Single Player: 15 energy
  - Multiplayer: 20 energy
  - Adventure Dungeons: 10-30 energy (based on level)
- **Difficulty Multipliers**:
  - Easy: 0.8x cost
  - Medium: 1.0x cost (normal)
  - Hard: 1.3x cost

#### Adventure Progression:
- **Levels**: Players earn experience in dungeons
- **Experience to Level Up**: Increases by 50% each level
- **Reward Scaling**: Rewards increase with dungeon difficulty and player performance

---

### 2. **Teacher Portal** 🎓
An intuitive optional dashboard for educators to manage classes and customize game settings.

#### Key Features:
- **Teacher Authentication**: Secure login system for educators
- **Class Management**: Create and manage multiple classes
- **Game Settings Control**:
  - Restrict specific difficulty levels
  - Adjust time limits (0.5x to 2.0x multiplier)
  - Adjust energy consumption (0.5x to 2.0x multiplier)
- **Class Analytics**: Track student performance and statistics
- **Completely Optional**: Teacher Portal is disabled by default and must be explicitly enabled

#### How to Enable Teacher Portal:

The Teacher Portal is completely optional and only needed for educational installations. To enable it:

**Method 1: Via Feature Config (Programmatic)**
```gdscript
FeatureConfig.set_teacher_portal_enabled(true)
FeatureConfig.set_teacher_mode_active(true)
```

**Method 2: Via Configuration File**
Edit `user://gameconfig.json`:
```json
{
	"teacher_portal_enabled": true,
	"energy_system_enabled": true,
	"adventure_mode_enabled": true,
	"multiplayer_enabled": true,
	"teacher_settings": {
		"class_code": "",
		"difficulty_restrictions": [],
		"time_limit_multiplier": 1.0,
		"energy_cost_multiplier": 1.0,
		"max_players_per_class": 30,
		"class_name": "",
		"teacher_name": "",
		"session_active": false
	}
}
```

#### Teacher Portal Features:

**Classes Tab**:
- View all created classes
- Create new classes
- Manage students per class
- View class statistics

**Settings Tab**:
- Restrict difficulty levels (Easy/Medium/Hard)
- Adjust time limits for problems
- Adjust energy costs
- Save settings per class

**Analytics Tab**:
- View class-wide statistics
- See student performance data
- Track average scores and completion times
- Identify top performers

#### Teacher Mode Restrictions:

When Teacher Mode is active, the following apply:
- Restricted difficulties are disabled
- Time limits are multiplied by the teacher's setting
- Energy costs are multiplied by the teacher's setting
- All changes are applied to that student's session

---

## 📊 System Architecture

### Core Systems

#### 1. **EnergySystem (Autoload)**
Located: `scripts/energy_system.gd`

Manages:
- Current energy tracking and persistence
- Energy regeneration over time
- Energy consumption for different game modes
- Energy rewards from gameplay
- Save/load energy data

Key Methods:
```gdscript
func consume_energy(amount: int) -> bool
func gain_energy(amount: int) -> void
func has_enough_energy(required: int) -> bool
func calculate_energy_cost(game_mode: String, difficulty: String) -> int
```

#### 2. **AdventureManager (Autoload)**
Located: `scripts/adventure_manager.gd`

Manages:
- Dungeon generation and map creation
- Adventure progression and leveling
- Experience tracking
- Dungeon rewards calculation
- Save/load adventure data

Key Methods:
```gdscript
func start_adventure() -> void
func enter_dungeon(dungeon_id: int) -> bool
func complete_dungeon(dungeon_id: int, score: int, time_taken: float) -> void
func gain_experience(amount: int) -> void
func get_adventure_summary() -> Dictionary
```

#### 3. **FeatureConfig (Autoload)**
Located: `scripts/feature_config.gd`

Manages:
- Feature toggles (Teacher Portal, Energy, Adventure)
- Teacher settings and restrictions
- Global configuration
- Configuration persistence

Key Methods:
```gdscript
func set_teacher_portal_enabled(enabled: bool) -> void
func set_energy_system_enabled(enabled: bool) -> void
func set_adventure_mode_enabled(enabled: bool) -> void
func is_difficulty_restricted(difficulty: String) -> bool
func get_time_limit_multiplier() -> float
func get_energy_cost_multiplier() -> float
```

### Scene Structure

**New Scenes**:
- `scenes/adventure_map.tscn` - Adventure map display and navigation
- `scenes/adventure_level.tscn` - Individual dungeon gameplay
- `scenes/teacher_portal.tscn` - Teacher portal interface

**Modified Scenes**:
- `scenes/main_menu.tscn` - Added Adventure Mode & Teacher Portal buttons

---

## 🔧 Integration with Existing Systems

### Single Player Mode
- Energy is consumed when starting a game
- Bonus energy awarded based on performance (accuracy)
- Energy requirement checked before game starts

### Multiplayer Mode
- Higher energy cost (20 units) to encourage adventure mode
- Energy synchronized across network

### Victory Screen
- Adventure rewards displayed when completing dungeons
- Experience progress shown

---

## 💾 Data Persistence

### Energy Data
Saved to: `user://energy_data.json`
```json
{
	"current_energy": 100,
	"total_energy_earned": 500,
	"total_energy_spent": 200,
	"last_regen_time": 1234567890.5
}
```

### Adventure Data
Saved to: `user://adventure_data.json`
```json
{
	"current_adventure": 0,
	"current_level": 5,
	"total_levels_completed": 12,
	"experience": 250,
	"experience_to_next_level": 150,
	"map_seed": 12345,
	"dungeons": [...]
}
```

### Feature Configuration
Saved to: `user://gameconfig.json`
Contains feature toggles and teacher settings

---

## 🎯 Configuration & Customization

### Disabling Features

To run MathBlat without certain features:

**Disable Adventure Mode**:
```gdscript
FeatureConfig.set_adventure_mode_enabled(false)
```

**Disable Energy System**:
```gdscript
FeatureConfig.set_energy_system_enabled(false)
```

**Disable Teacher Portal** (default):
```gdscript
FeatureConfig.set_teacher_portal_enabled(false)
```

### Customizing Energy Rates

Edit `energy_system.gd`:
```gdscript
const MAX_ENERGY: int = 100
const ENERGY_REGEN_RATE: float = 10.0  # Energy per minute
const SINGLE_PLAYER_COST: int = 15
const MULTIPLAYER_COST: int = 20
```

### Customizing Adventure Parameters

Edit `adventure_manager.gd`:
```gdscript
const DUNGEONS_PER_MAP: int = 5
const MAP_WIDTH: int = 800
const MAP_HEIGHT: int = 600
```

---

## 🧪 Testing the Features

### Test Adventure Mode:
1. Enable `adventure_mode_enabled` in FeatureConfig
2. Start game → Select "Adventure Mode"
3. Complete dungeons to progress
4. Check `user://adventure_data.json` for persistence

### Test Energy System:
1. Monitor `user://energy_data.json` for energy changes
2. Complete single-player games and check energy rewards
3. Wait 6 minutes to see energy regenerate from 0 to 100

### Test Teacher Portal:
1. Set `teacher_portal_enabled` to true
2. Login with any email (email validation only)
3. Modify settings and verify they apply to gameplay
4. Check configuration persists in `user://gameconfig.json`

---

## 🚀 Installation Instructions

1. **Copy the new files to your project**:
   - `scripts/energy_system.gd`
   - `scripts/adventure_manager.gd`
   - `scripts/feature_config.gd`
   - `scripts/adventure_map.gd`
   - `scripts/adventure_level.gd`
   - `scripts/teacher_portal.gd`
   - `scenes/adventure_map.tscn`
   - `scenes/adventure_level.tscn`
   - `scenes/teacher_portal.tscn`

2. **Update project.godot** autoloads section:
   ```
   [autoload]
   GameManager="*res://scripts/game_manager.gd"
   HighScoreManager="*res://scripts/high_score_manager.gd"
   EnergySystem="*res://scripts/energy_system.gd"
   AdventureManager="*res://scripts/adventure_manager.gd"
   FeatureConfig="*res://scripts/feature_config.gd"
   ```

3. **Update main_menu.tscn** to add buttons for Adventure Mode and Teacher Portal

4. **Test the features** following the testing guide above

---

## 📝 Notes

- All features are completely optional and can be disabled
- The teacher portal requires no backend infrastructure for basic use
- Energy regenerates automatically even when the game is closed
- All player data is stored locally (can be synced to cloud if desired)
- The energy system balances gameplay to encourage adventure mode progression

---

## 🐛 Troubleshooting

**Adventure Mode button doesn't appear**:
- Check `FeatureConfig.adventure_mode_enabled` is true
- Rebuild the main_menu.tscn with the Adventure button

**Energy not regenerating**:
- Make sure EnergySystem autoload is registered
- Check `user://energy_data.json` exists and is valid

**Teacher Portal won't login**:
- Make sure `FeatureConfig.teacher_portal_enabled` is true
- Check that email field has valid format (contains @)
- Password must be at least 6 characters

**Adventure dungeons locked**:
- Complete previous dungeon first
- Check energy is sufficient
- Verify `adventure_manager.gd` can_enter_dungeon logic
