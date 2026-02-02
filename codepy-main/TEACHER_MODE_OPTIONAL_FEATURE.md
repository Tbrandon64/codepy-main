# Teacher Mode - Optional Feature

## Overview

**Teacher Mode is an OPTIONAL feature** that only works if the teacher mode system files are installed and available.

The game will continue to function normally with basic math problems even if teacher mode is not installed.

---

## When Teacher Mode is Available

Teacher mode provides advanced problem types:
- ✅ PEMDAS (Order of Operations)
- ✅ Square Root Problems
- ✅ Long Division

These features are ONLY available if:
1. `scripts/teacher_mode_system.gd` exists in the Godot project
2. `python_backup/teacher_mode.py` exists in the Python backup directory
3. The teacher mode systems successfully initialize

---

## When Teacher Mode is NOT Available

If teacher mode is not installed:
- ✅ Game continues to run normally
- ✅ Basic math problems still generate
- ✅ No errors or crashes occur
- ✅ TeacherPortal displays basic problems only
- ⚠️ Advanced problem types unavailable

---

## Game Manager Integration

### Checking Teacher Mode Availability

```gdscript
# Check if teacher mode is available
if GameManager.is_teacher_mode_available():
	# Teacher mode is available - can use advanced features
	var problem = GameManager.generate_teacher_problem("PEMDAS", "INTERMEDIATE")
else:
	# Teacher mode not available - use basic problems
	var problem = GameManager.generate_problem()
```

### Safe Usage

```gdscript
# This safely returns a problem or empty dict if not available
var teacher_problem = GameManager.generate_teacher_problem("SQUARE_ROOT", "FOUNDATIONAL")

if teacher_problem.is_empty():
	# Teacher mode not available, use basic problem instead
	teacher_problem = GameManager.generate_problem()
else:
	# Teacher mode available, use advanced problem
	display_problem(teacher_problem)
```

---

## Python Backup System

### Optional Initialization

The Python BackupSystem will attempt to load teacher mode but won't fail if it's not available:

```python
backup = BackupSystem()

# Check if teacher mode is available
if backup.teacher_mode is not None:
	problem = backup.generate_pemdas_problem("ADVANCED")
else:
	# Teacher mode not available, use basic problem
	problem = backup.generate_problem("HARD")
```

### Error Messages

If teacher mode is requested but not available:
```
⚠️ Teacher mode not available (optional feature)
```

This is NOT an error - it's just informational logging.

---

## Installation Instructions

### To Enable Teacher Mode

1. Ensure these files exist in your project:
   ```
   scripts/teacher_mode_system.gd
   python_backup/teacher_mode.py
   ```

2. Restart the game/application

3. Teacher mode will automatically initialize if files are present

### To Disable Teacher Mode

Simply remove or rename the teacher mode files:
- `scripts/teacher_mode_system.gd` → `scripts/teacher_mode_system.gd.disabled`
- `python_backup/teacher_mode.py` → `python_backup/teacher_mode.py.disabled`

The game will continue working normally with basic problems.

---

## Implementation Details

### Godot GameManager

```gdscript
# Teacher mode is initialized optionally
func _initialize_teacher_mode() -> void:
    try:
        teacher_mode = TeacherModeSystem.new()
        teacher_mode_available = true
        print("✅ Teacher Mode initialized successfully")
    except:
        teacher_mode = null
        teacher_mode_available = false
        print("⚠️  Teacher Mode not available (optional feature)")

# Check before using
func generate_teacher_problem(type: String, difficulty: String) -> Dictionary:
    if not teacher_mode_available or teacher_mode == null:
        print("⚠️  Teacher mode not available - returning basic problem")
        return {}
    # ... generate problem
```

### Python BackupSystem

```python
# Teacher mode is optional during initialization
def _initialize_systems(self) -> None:
    try:
        self.problem_gen = ProblemGenerator(difficulty="MEDIUM")
        self.score_manager = ScoreManager()
        self.config_manager = ConfigManager()
        
        # Teacher mode is optional - load if available
        try:
            self.teacher_mode = TeacherMode()
            print("✅ All systems initialized (including optional teacher mode)")
        except Exception as te:
            self.teacher_mode = None
            print(f"⚠️  Teacher mode not available (optional): {te}")
```

---

## Status Reporting

### Godot

```gdscript
var available = GameManager.is_teacher_mode_available()
# Returns: true if teacher mode is ready, false otherwise
```

### Python

```python
status = backup.get_status()
if status['teacher_mode']:
    print("✅ Teacher Mode Available")
else:
    print("⚠️  Teacher Mode Not Available (Optional)")
```

---

## Graceful Degradation

The system is designed to gracefully handle teacher mode being unavailable:

```
User requests PEMDAS problem
    ↓
Check if teacher mode available
    ↓
YES → Generate PEMDAS problem
NO  → Generate basic math problem
    ↓
Return problem to player
```

No errors. No crashes. Just graceful fallback.

---

## FAQ

### Q: Will the game crash if teacher mode files are missing?
**A:** No. The game will work normally with basic problems.

### Q: Do I need to install teacher mode?
**A:** No. It's completely optional. The game works fine without it.

### Q: How do I know if teacher mode is available?
**A:** Use `GameManager.is_teacher_mode_available()` in Godot or check `backup.teacher_mode is not None` in Python.

### Q: What if teacher mode partially loads but fails?
**A:** It's handled gracefully. The teacher mode methods will return empty dicts, and the game continues with basic problems.

### Q: Can I have both basic and teacher mode problems?
**A:** Yes! If teacher mode is available, call `generate_teacher_problem()`. If not available or you want basic problems, call `generate_problem()`.

### Q: Will enabling/disabling teacher mode affect my saves?
**A:** No. Scores and progress are stored separately and not affected by teacher mode availability.

---

## Example Usage

### Check Availability and Respond

```gdscript
# In TeacherPortal script
func _ready():
    if GameManager.is_teacher_mode_available():
        print("✅ Advanced problem types available")
        $ProblemTypeSelector.visible = true
        $ProblemTypeSelector.add_item("PEMDAS")
        $ProblemTypeSelector.add_item("SQUARE_ROOT")
        $ProblemTypeSelector.add_item("LONG_DIVISION")
    else:
        print("⚠️  Advanced features not available - using basic problems only")
        $ProblemTypeSelector.visible = false
        $BasicProblemGenerator.visible = true
```

### Safe Problem Generation

```gdscript
func generate_next_problem():
    if GameManager.is_teacher_mode_available():
        var problem = GameManager.generate_teacher_problem(selected_type, selected_difficulty)
        if problem.is_empty():
            # Fallback if generation failed
            problem = GameManager.generate_problem()
    else:
        problem = GameManager.generate_problem()
    
    display_problem(problem)
```

---

## Summary

✅ **Teacher Mode is optional**
✅ **Game works fine without it**
✅ **Graceful fallback to basic problems**
✅ **Easy to enable/disable**
✅ **No errors or crashes**
✅ **Clear status reporting**

**Recommendation**: Deploy with or without teacher mode based on your needs. Either way, the game will work perfectly.
