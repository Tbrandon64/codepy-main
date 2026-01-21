# MathBlat Code Style Guide

## Overview
This guide documents the code organization, naming conventions, and best practices used throughout the MathBlat project to ensure consistency and readability.

---

## File Organization

### Directory Structure
```
codepy-main/
├── scripts/              # Godot GDScript files
│   ├── core/            # Core game logic
│   ├── ui/              # UI scripts (future)
│   ├── systems/         # Optional systems
│   └── utils/           # Utilities (future)
├── scenes/              # Godot scene files
├── python_backup/       # Python backup systems
├── docs/                # Documentation
└── README.md            # Project overview
```

### Naming Convention: Files

**GDScript files** (.gd):
- Use snake_case
- Descriptive, specific names
- Examples: `game_manager.gd`, `audio_manager.gd`, `teacher_mode_system.gd`

**Scene files** (.tscn):
- Use snake_case
- Match core logic filename where possible
- Examples: `game_scene.tscn`, `main_menu.tscn`

**Python files** (.py):
- Use snake_case
- Descriptive names
- Examples: `problem_generator.py`, `backup_system.py`

---

## Code Organization Within Files

### File Header
```gdscript
extends Node

## System: Brief 1-line description
## Purpose: What this system does
## Features: Key capabilities
## Optional: If this is an optional system, state "Optional - graceful fallback"

class_name ClassName
```

### Variable Organization

**Order of Declaration**:
1. Class variables (state)
2. Enums (if any)
3. Signals (if any)
4. Private variables (with underscore prefix)
5. Constants (if any)

```gdscript
# Public state
var score: int = 0
var difficulty: Difficulty = Difficulty.EASY

# Difficulty enum
enum Difficulty {EASY, MEDIUM, HARD}

# Signals
signal score_changed

# Cached/internal data (private)
var _cache: Dictionary = {}
var _is_initialized: bool = false

# Constants
const MAX_CACHE_SIZE: int = 100
```

### Method Organization

**Order of Declaration**:
1. `_ready()` or `_init()` (lifecycle)
2. Public methods (API)
3. Private methods (implementation)
4. Helpers/Utilities

```gdscript
func _ready() -> void:
    # Initialization

func generate_problem() -> Dictionary:
    # Public API

func _calculate_answer() -> void:
    # Private implementation

func _validate_input(value: String) -> bool:
    # Helper
```

---

## Naming Conventions

### Variables

**Public Variables** (no prefix):
```gdscript
var score: int = 0
var current_difficulty: Difficulty = Difficulty.EASY
var master_volume: float = 1.0
```

**Private Variables** (underscore prefix):
```gdscript
var _cache: Dictionary = {}
var _is_initialized: bool = false
var _ding_stream: AudioStreamWAV
```

**Boolean Variables** (use "is_", "has_", "enable_", "can_"):
```gdscript
var is_sound_enabled: bool = true
var has_audio_bus: bool = false
var can_generate_teacher_problems: bool = false
```

### Functions

**Public Functions** (full descriptive name):
```gdscript
func generate_problem() -> MathProblem:
func check_answer(selected_answer: int) -> bool:
func set_master_volume(volume: float) -> void:
```

**Private Functions** (underscore prefix, descriptive):
```gdscript
func _calculate_correct_answer(problem: MathProblem) -> void:
func _generate_options(correct_answer: int) -> Array[int]:
func _validate_input(key: String) -> bool:
```

**Short, Clear Names** (avoid abbreviations):
```gdscript
# Good
func set_volume(v: float) -> void:  # Parameter can be short
func check_answer() -> bool:

# Avoid
func sv(v: f) -> v:  # Too cryptic
func chk_ans() -> b:  # Unnecessarily abbreviated
```

### Constants

**Use UPPER_CASE**:
```gdscript
const MAX_CACHE_SIZE: int = 100
const DEFAULT_VOLUME: float = 1.0
const DIFFICULTY_RANGES: Dictionary = {
    Difficulty.EASY: {"min": 1, "max": 10}
}
```

### Enums

**Use UPPER_CASE for values**:
```gdscript
enum Difficulty {EASY, MEDIUM, HARD}
enum ProblemType {PEMDAS, SQUARE_ROOT, LONG_DIVISION}
```

---

## Comments

### Comment Style

**Single-line comment for class/method documentation**:
```gdscript
## Generate math problem with current difficulty
func generate_problem() -> MathProblem:
```

**Multi-line for complex explanations**:
```gdscript
## Calculate correct answer based on operation
## Division handled specially to ensure whole number result
## Returns: Modifies problem.correct_answer in-place
func _calculate_correct_answer(problem: MathProblem) -> void:
```

**Inline comments for clarification**:
```gdscript
# Ensure divisor is not zero
if problem.operand2 == 0:
    problem.operand2 = 1

# Set dividend as multiple of divisor for clean division
problem.operand1 = problem.correct_answer * problem.operand2
```

### What to Document

✅ **Document These**:
- Public method purpose and parameters
- Non-obvious logic
- Why something is done a certain way (especially optimizations)
- Failure modes and fallbacks

❌ **Don't Overcomment**:
```gdscript
# Bad: Obvious from code
var score = 0  # Initialize score to 0
x = x + 1  # Increment x

# Good: Explains why
var _cache: Dictionary = {}  # Store recent problems to avoid regeneration
```

---

## Formatting & Spacing

### Indentation
- Use **tabs** (configured in Godot)
- 1 tab = 1 indentation level
- Consistent across all files

### Line Length
- Keep lines under 100 characters when practical
- Exception: URLs, long strings

### Blank Lines
- 1 blank line between methods
- 2 blank lines between major sections
- No blank lines at start/end of file

```gdscript
extends Node

class_name GameManager


# State
var score: int = 0


func _ready() -> void:
    pass


func generate_problem() -> Dictionary:
    pass


func _calculate_answer() -> void:
    pass
```

### Spacing in Code
```gdscript
# Good
var result = (a + b) * c
if is_valid and has_data:
    do_something()

# Avoid
var result=(a+b)*c
if is_valid and has_data:do_something()
```

---

## Type Hints

### Always Use Type Hints
```gdscript
# Good
func set_volume(volume: float) -> void:
    master_volume = clamp(volume, 0.0, 1.0)

# Avoid
func set_volume(volume):
    master_volume = clamp(volume, 0.0, 1.0)
```

### Return Types
```gdscript
func get_volume() -> float:
    return master_volume

func generate_options(answer: int) -> Array[int]:
    return options

func is_valid() -> bool:
    return true
```

### Optional Parameters
```gdscript
func get_text(key: String, default_text: String = "") -> String:
    return translations.get(key, default_text)
```

---

## Error Handling

### Fail-Safe Pattern
```gdscript
func method_name(param: String) -> ReturnType:
    try:
        # Input validation
        if not param or param.is_empty():
            print("WARNING: method_name received empty param")
            return FALLBACK_VALUE
        
        # Main logic
        var result = do_something(param)
        return result
    except:
        print("ERROR: method_name failed for '%s'" % param)
        return FALLBACK_VALUE
```

### Error Messages
- Use clear, actionable messages
- Include relevant parameters
- Use consistent format: `"[LEVEL]: [System] [Issue], [Recovery]"`

```gdscript
# Good
print("WARNING: Failed to set master volume, using default (1.0)")
print("ERROR: Unknown operation '%s', defaulting to '+'" % op)

# Avoid
print("ERROR!")
print("Something went wrong")
```

---

## Function Documentation Example

```gdscript
## Generate math problem with current difficulty
## 
## Creates a problem with 4 answer options, including 1 correct
## and 3 plausible wrong answers.
##
## Returns: MathProblem struct with all fields populated
func generate_problem() -> MathProblem:
    pass
```

---

## Consistency Checklist

- [ ] All files use consistent indentation (tabs)
- [ ] Variable names follow snake_case (public) and _snake_case (private)
- [ ] All functions have type hints
- [ ] All public methods have documentation comments
- [ ] Private methods have brief explanatory comments
- [ ] Error messages are clear and actionable
- [ ] Spacing and formatting consistent within file
- [ ] Method order: _ready() → public → private → helpers
- [ ] Constants use UPPER_CASE
- [ ] Enums use UPPER_CASE values

---

## Common Patterns

### Optional System Pattern
```gdscript
# At init
var optional_system: OptionalSystem = null
var _system_initialized: bool = false

# Lazy-load only if needed
func _initialize_optional_system() -> void:
    if _system_initialized:
        return
    
    _system_initialized = true
    
    try:
        optional_system = OptionalSystem.new()
    except:
        optional_system = null
        print("WARNING: Optional system unavailable")

# Check before use
if optional_system:
    optional_system.do_something()
```

### Fallback Pattern
```gdscript
func generate_something() -> Dictionary:
    try:
        return _generate_main()
    except:
        return _generate_fallback()

func _generate_main() -> Dictionary:
    # Complex generation
    pass

func _generate_fallback() -> Dictionary:
    # Simple hardcoded fallback
    return {"value": 0}
```

---

## Performance Notes

- Avoid creating new objects in loops (cache instead)
- Use dictionaries for O(1) lookups
- Pre-allocate arrays when size known
- Mark heavy operations with comments for future optimization
- Profile before optimizing

---

## Review Checklist for Pull Requests

- [ ] Follows naming conventions
- [ ] Functions documented (public methods)
- [ ] Type hints on all functions
- [ ] Consistent spacing and indentation
- [ ] Error handling with try-catch where appropriate
- [ ] No unnecessary abbreviations
- [ ] Comments explain "why", not "what"
- [ ] Method order logical
- [ ] Tests included for new functionality

---

## Questions?

Refer to:
1. Existing code for examples
2. This guide for conventions
3. Godot documentation for language features
4. Comments in complex code sections

---

**Last Updated**: January 20, 2026
**Status**: Active - All systems follow this guide
