# Code Standards and Best Practices

This document defines the coding standards, naming conventions, and formatting guidelines for the MathBlat project. All contributors should follow these guidelines to maintain consistency and code quality.

## Table of Contents

1. [General Principles](#general-principles)
2. [Python Code Standards](#python-code-standards)
3. [GDScript Code Standards](#gdscript-code-standards)
4. [Naming Conventions](#naming-conventions)
5. [Comments and Documentation](#comments-and-documentation)
6. [File Organization](#file-organization)
7. [Performance Considerations](#performance-considerations)

---

## General Principles

### Code Quality Goals

1. **Readability**: Code should be clear and easy to understand at a glance
2. **Maintainability**: Other developers should be able to modify code safely
3. **Performance**: Avoid unnecessary allocations, loops, and computations
4. **Consistency**: All code should follow the same patterns and style
5. **Documentation**: Complex logic should be explained with comments

### Core Rules

- Write code for humans first, machines second
- Use meaningful names that explain purpose
- Add comments for "why", not "what" (code shows what, comments explain why)
- Keep functions focused on a single responsibility
- Use consistent indentation and spacing throughout

---

## Python Code Standards

### File Structure

```python
#!/usr/bin/env python3
"""
Module docstring: Brief description of module purpose.

Extended description with details about what the module does,
main classes, and usage examples if complex.

Usage:
    from module import ClassName
    obj = ClassName()
    result = obj.do_something()
"""

# Standard library imports
import sys
from pathlib import Path
from typing import Dict, Optional

# Third-party imports
import requests

# Local imports
from local_module import LocalClass


class MyClass:
    """Class docstring with description."""
    
    CONSTANT_VALUE = 100  # Class constants in UPPER_CASE
    
    def __init__(self):
        """Initialize the class."""
        self.instance_variable = None
```

### Naming Conventions (Python)

| Element | Convention | Example |
|---------|-----------|---------|
| Classes | PascalCase | `class MathProblem` |
| Functions | snake_case | `def generate_problem()` |
| Variables | snake_case | `player_score = 100` |
| Constants | UPPER_SNAKE_CASE | `MAX_HIGH_SCORES = 10` |
| Private methods | _snake_case prefix | `def _initialize_systems()` |
| Private variables | _snake_case prefix | `self._cache_size = 5` |

### Function Documentation (Python)

```python
def save_score(self, player_name: str, score: int, difficulty: str) -> bool:
    """Save a high score entry with validation.
    
    Validates player name length and score value before storage.
    Automatically maintains top 10 scores in ranked order.
    
    Args:
        player_name: Name of the player (max 50 characters)
        score: Score achieved (positive integer)
        difficulty: Difficulty level (EASY, MEDIUM, HARD)
    
    Returns:
        True if score saved successfully, False on error
    
    Raises:
        ValueError: If score is negative
    """
    # Implementation here
    pass
```

### Comment Style (Python)

```python
# Good: Explains WHY this is done
if operand2 == 0:
    return None  # Prevent division by zero

# Good: Multi-line explanation of complex logic
# Generate quotient first, then set dividend as a clean multiple
# This ensures division without remainders
problem.correct_answer = randi_range(1, max_quotient)
problem.operand1 = problem.correct_answer * problem.operand2

# Bad: Explains WHAT the code does (obvious from reading)
# Add one to x
x = x + 1

# Bad: Excessive comments
# Loop through all options  <-- Obvious from code
for option in options:
    # Check if option is in list  <-- Obvious from code
    if option not in used:
        # Add to used list  <-- Obvious from code
        used.append(option)
```

---

## GDScript Code Standards

### File Structure

```gdscript
extends Node

## Class documentation using GDScript markdown format.
##
## Extended description with details about functionality.
## Multiple lines are supported with ## prefix.

class_name MyManager

# Module constants (UPPER_CASE)
const MAX_ITEMS = 10
const DEFAULT_DIFFICULTY = "MEDIUM"

# Exported variables for editor configuration
@export var enabled: bool = true
@export var debug_mode: bool = false

## Internal state variables (private, single ##)
var _current_state: String = "idle"
var _is_initialized: bool = false

## Public state variables (double ##)
var score: int = 0
var player_name: String = ""

# Nested class definitions
class GameState:
    var level: int
    var progress: float

func _ready() -> void:
    ## Called when scene enters tree
    _initialize()

## Helper method (documented with ##)
func _initialize() -> void:
    # Implementation here
    pass
```

### Naming Conventions (GDScript)

| Element | Convention | Example |
|---------|-----------|---------|
| Classes | PascalCase | `class MyManager` |
| Functions | snake_case | `func generate_problem()` |
| Variables | snake_case | `var player_score = 0` |
| Constants | UPPER_SNAKE_CASE | `const MAX_SCORE = 1000` |
| Private methods | _snake_case prefix | `func _initialize()` |
| Private variables | _snake_case prefix | `var _cache_size: int` |
| Signals | snake_case | `signal player_died(player_name)` |
| Enums | PascalCase + UPPER enum values | `enum State {IDLE, RUNNING, PAUSED}` |

### Function Documentation (GDScript)

```gdscript
## Generate a new math problem.
##
## Creates a random problem based on difficulty setting.
## Handles division specially to ensure whole number results.
##
## Args:
##   (none - uses class difficulty setting)
##
## Returns:
##   MathProblem with all fields populated
func generate_problem() -> MathProblem:
    # Implementation here
    pass

## Calculate answer for operation.
##
## Validates operation and operands before calculation.
##
## Args:
##   op1: First operand
##   op2: Second operand  
##   operation: Operation symbol ("+", "-", "*", "/")
##
## Returns:
##   Calculated result or null if invalid
func _calculate_answer(op1: int, op2: int, operation: String) -> Variant:
    # Implementation here
    pass
```

### Comment Style (GDScript)

```gdscript
# Good: Explains the reason for special handling
if operation == "/":
    # Division: ensure clean division with no remainders
    if operand2 == 0:
        return None  # Prevent division by zero
    return operand1 // operand2

# Good: Clarifies complex algorithm
# Generate quotient first, then set dividend as a clean multiple
# This ensures division always produces whole number results
problem.correct_answer = randi_range(1, max_quotient)
problem.operand1 = problem.correct_answer * problem.operand2

# Bad: Obvious from code
var x = x + 1  # Add 1 to x

# Bad: Commenting every line (noise)
var options = []  # Create empty array
options.append(correct_answer)  # Add correct answer
options.shuffle()  # Shuffle the options
```

---

## Naming Conventions

### Variable Naming Guide

```python
# Good: Clear, descriptive names
player_score = 100
max_difficulty_range = 100
is_game_running = True
problem_generator = ProblemGenerator()

# Bad: Too vague
ps = 100  # What is ps? Player score? Point system?
mdr = 100  # Unclear abbreviation
running = True  # Running what?
gen = ProblemGenerator()  # What kind of generator?

# Good: Boolean prefix indicates true/false nature
is_available = True
has_teacher_mode = False
should_continue = True
enabled = True

# Bad: Unclear boolean meaning
available = True  # What is available? Do we get it if true or false?
teaching = False  # Does this mean "is teaching" or "should teach"?
continue_game = True  # Is this a question or a command?
```

### Function Naming Guide

```python
# Good: Action verbs describe what function does
def generate_problem():
def save_score():
def load_configuration():
def validate_answer():
def initialize_systems():

# Bad: Unclear purpose
def do_something():  # What does it do?
def process():  # Process what?
def handle():  # Handle what?

# Good: Boolean functions use "is_", "has_", "can_", "should_"
def is_high_score(score):
def has_teacher_mode():
def can_generate_problem():
def should_save_settings():

# Bad: Unclear boolean return
def check_score(score):  # Returns bool? int? None?
def validate(data):  # Returns bool? Raises exception?
def verify_system():  # Returns bool or bool array?
```

---

## Comments and Documentation

### When to Add Comments

| Situation | Example | When to Comment |
|-----------|---------|-----------------|
| Complex algorithm | Quadratic formula | Always - explain the math |
| Non-obvious decision | Using `//` not `%` for division | Yes - explain WHY |
| Performance optimization | Caching difficulty ranges | Yes - explain tradeoff |
| Workaround/hack | Using `max(1, value)` to prevent zero | Yes - explain limitation |
| Business logic | Keeping top 10 scores | Yes - explain requirement |
| Obvious code | `x = x + 1` | No - code is clear |
| Standard patterns | Standard for loop | No - pattern is familiar |
| Well-named code | `if is_player_score_high:` | Maybe - name explains itself |

### Documentation Levels

#### Level 1: Module Docstring

```python
"""
Brief one-line description.

Longer paragraph explaining the module's purpose, main classes,
key functionality, and typical usage patterns.

Usage:
    from module import MainClass
    obj = MainClass()
    result = obj.main_method()
"""
```

#### Level 2: Class Docstring

```python
class ScoreManager:
    """Manage high scores with persistent JSON storage.
    
    Stores player scores with automatic ranking, keeps top 10,
    and persists to ~/.mathblat/high_scores.json.
    """
```

#### Level 3: Method Docstring

```python
def save_score(self, player_name: str, score: int, difficulty: str) -> bool:
    """Save high score with automatic ranking update.
    
    Args:
        player_name: Player name (max 50 chars)
        score: Score value (positive integer)
        difficulty: Difficulty level
    
    Returns:
        True if saved successfully, False otherwise
    """
```

#### Level 4: Inline Comments

```python
# Use sparingly for non-obvious logic
if operand2 == 0:
    return None  # Prevent division by zero
```

---

## File Organization

### Python Project Structure

```
python_backup/
├── __init__.py                 # Package marker
├── backup_system.py            # Main interface (imports all others)
├── problem_generator.py        # Problem generation logic
├── score_manager.py            # Score persistence
├── config_manager.py           # Configuration management
├── teacher_mode.py             # Advanced problem types
└── README.md                   # Module documentation
```

### GDScript Project Structure

```
scripts/
├── managers/                   # Manager systems
│   ├── game_manager.gd
│   ├── audio_manager.gd
│   └── system_manager.gd
├── gameplay/                   # Gameplay logic
│   ├── difficulty_menu.gd
│   ├── game_scene.gd
│   └── victory_screen.gd
├── ui/                         # UI components
│   ├── main_menu.gd
│   └── teacher_portal.gd
└── systems/                    # Game systems
    ├── achievement_system.gd
    └── energy_system.gd
```

### Meaningful File Names

```
Good: Clearly describes content
- backup_system.py
- game_manager.gd
- problem_generator.py
- score_manager.py
- teacher_mode.py

Avoid: Too generic or vague
- utils.py  (What utilities?)
- helper.gd  (What kind of help?)
- system.py  (Which system?)
- main.gd  (Of what?)
```

---

## Performance Considerations

### Python Performance

```python
# Good: Cache rarely-changing data
DIFFICULTY_RANGES = {
    "EASY": {"min": 1, "max": 10},
    "MEDIUM": {"min": 1, "max": 50},
    "HARD": {"min": 1, "max": 100},
}

# Good: Reuse arrays to avoid allocation
OPERATIONS = ["+", "-", "*", "/"]

# Bad: Creating new arrays every time
def get_operations():
    return ["+", "-", "*", "/"]  # New list each call!
```

### GDScript Performance

```gdscript
# Good: Pre-allocate and reuse
var _operations: Array[String] = ["+", "-", "*", "/"]

# Good: Cache difficulty ranges
var _difficulty_ranges: Dictionary = {
    Difficulty.EASY: {"min": 1, "max": 10},
    Difficulty.MEDIUM: {"min": 1, "max": 50},
}

# Bad: Allocating in hot loop
func generate_many_problems():
    for i in range(1000):
        var ops = ["+", "-", "*", "/"]  # Allocates 1000 times!
```

### Lazy Loading Pattern

```python
# Good: Initialize on first use, not startup
def _initialize_teacher_mode(self) -> None:
    if self._teacher_mode_initialized:
        return  # Already attempted
    
    self._teacher_mode_initialized = True
    
    try:
        self.teacher_mode = TeacherMode()
    except:
        self.teacher_mode = None
```

---

## Code Review Checklist

Before submitting code, verify:

- [ ] All functions have docstrings explaining purpose, args, and returns
- [ ] Variable names are descriptive (3-4 words typically)
- [ ] Comments explain WHY, not WHAT
- [ ] No obvious performance issues (allocations in loops, etc.)
- [ ] Consistent formatting throughout (spacing, indentation)
- [ ] Error handling with try/except where needed
- [ ] Private methods/variables start with underscore
- [ ] Constants are UPPER_SNAKE_CASE
- [ ] No dead code or commented-out lines left
- [ ] File organization is logical

---

## Examples: Before and After

### Example 1: Python Function Improvement

**Before:**
```python
def gp(d):
    # gen prob
    r = RANGES[d]
    a = rand(r['min'], r['max'])
    b = rand(r['min'], r['max'])
    o = choice(OPS)
    c = calc(a, b, o)
    t = f"{a} {o} {b} = ?"
    opts = gen_opts(c)
    return {"a": a, "b": b, "o": o, "c": c, "t": t, "opts": opts}
```

**After:**
```python
def generate_problem(self) -> Dict:
    """Generate a math problem based on current difficulty.
    
    Returns:
        Dictionary with operand1, operand2, operation, correct_answer,
        problem_text, and multiple choice options
    """
    # Get difficulty-specific number range
    difficulty_config = self.DIFFICULTY_RANGES[self.current_difficulty]
    min_value = difficulty_config["min"]
    max_value = difficulty_config["max"]
    
    # Generate random operands within range
    operand1 = random.randint(min_value, max_value)
    operand2 = random.randint(min_value, max_value)
    
    # Select random operation
    operation = random.choice(self.OPERATIONS)
    
    # Calculate correct answer
    correct_answer = self._calculate_answer(operand1, operand2, operation)
    
    # Format problem for display
    problem_text = f"{operand1} {operation} {operand2} = ?"
    
    # Generate multiple choice options
    options = self._generate_options(correct_answer)
    
    return {
        "operand1": operand1,
        "operand2": operand2,
        "operation": operation,
        "correct_answer": correct_answer,
        "problem_text": problem_text,
        "options": options
    }
```

### Example 2: GDScript Function Improvement

**Before:**
```gdscript
func gen() -> Dictionary:
    var r = ranges[diff]
    var a = randi_range(r["min"], r["max"])
    var b = randi_range(r["min"], r["max"])
    var o = ops[randi() % ops.size()]
    calc(a, b, o)
    return {a: a, b: b, o: o, c: ans}
```

**After:**
```gdscript
## Generate a new math problem.
##
## Creates problem with random operands from difficulty range,
## random operation, and multiple choice options.
##
## Returns:
##   Dictionary with operand1, operand2, operation, correct_answer, options
func generate_problem() -> Dictionary:
    # Get difficulty-specific range
    var range_config = _difficulty_ranges[current_difficulty]
    var min_value = range_config["min"]
    var max_value = range_config["max"]
    
    # Generate operands
    var operand1 = randi_range(min_value, max_value)
    var operand2 = randi_range(min_value, max_value)
    
    # Select operation
    var operation = _operations[randi() % _operations.size()]
    
    # Calculate answer
    var correct_answer = _calculate_answer(operand1, operand2, operation)
    
    # Generate options
    var options = _generate_options(correct_answer)
    
    return {
        "operand1": operand1,
        "operand2": operand2,
        "operation": operation,
        "correct_answer": correct_answer,
        "options": options
    }
```

---

## Additional Resources

- **Python PEP 8**: https://pep8.org/
- **Google Python Style Guide**: https://google.github.io/styleguide/pyguide.html
- **GDScript Best Practices**: https://docs.godotengine.org/en/stable/getting_started/scripting/gdscript/index.html
- **Clean Code**: Tips from Robert C. Martin's "Clean Code"

---

**Version**: 1.0  
**Last Updated**: 2026-01-20  
**Maintained By**: Development Team
