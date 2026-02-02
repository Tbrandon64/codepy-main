# Quick Reference - Coding Standards

**TL;DR version of CODE_STANDARDS.md for quick lookup**

---

## Naming Quick Reference

### Variables
```python
# Good naming pattern
player_score = 100          # Clear subject_object
max_difficulty = 100        # Bounds are clear
is_game_running = True      # Boolean is_ prefix
_cache_size = 5            # Private with underscore
```

### Functions
```python
# Action verbs for functions
def generate_problem()      # Creates something
def save_score()           # Stores something
def load_config()          # Retrieves something

# Boolean predicates
def is_available()         # Returns true/false
def has_teacher_mode()     # Returns true/false
def can_generate()         # Returns true/false
def should_continue()      # Returns true/false
```

### Constants
```python
MAX_HIGH_SCORES = 10       # UPPER_SNAKE_CASE
DEFAULT_DIFFICULTY = "EASY"
MIN_VALUE = 1
```

---

## Docstring Templates

### Python Function
```python
def function_name(param1: str, param2: int) -> bool:
	"""Short one-line description.
    
    Longer explanation if needed with more details
    about what the function does and why.
    
    Args:
        param1: Description of param1
        param2: Description of param2 (default value if any)
    
    Returns:
        Description of return value
    
    Raises:
        ValueError: When something is invalid
	"""
	pass
```

### Python Class
```python
class ClassName:
	"""Short description of class.
    
    Longer description explaining purpose, key features,
    and typical usage patterns.
	"""
	
	# Constants
	MAX_ITEMS = 10
	
	def __init__(self):
		"""Initialize the class."""
		pass
```

### GDScript Function
```gdscript
## Short description here.
##
## Longer description with more details about what
## the function does and how to use it.
##
## Args:
##   param_name: Description of parameter
##
## Returns:
##   Description of return value
func function_name(param_name: Type) -> ReturnType:
	pass
```

### GDScript Class
```gdscript
## Class description with what it manages.
##
## Extended description of functionality,
## key features, and integration points.

class_name ClassName

const CONSTANT = 10  ## What this constant represents
var member_var = ""  ## What this variable tracks
```

---

## Comment Style Quick Guide

### GOOD Comments (Explain WHY)
```python
# Prevent division by zero
if divisor == 0:
	return None

# Cache difficulty ranges to avoid repeated lookups during gameplay
_difficulty_ranges = {...}

# Shuffle options so correct answer isn't always in same position
options.shuffle()
```

### BAD Comments (Explain WHAT - obvious from code)
```python
# Add 1 to x
x = x + 1

# Create empty list
options = []

# Check if value is in list
if value in list:
    ...
```

---

## Formatting Rules

### Python
```python
# 4-space indentation
if condition:
    do_something()  # 4 spaces from line above

# Spacing around operators
x = 10          # Space around =
result = a + b  # Space around +

# Line length: aim for < 100 characters
short_name = some_function(param1, param2)  # Good
very_long_function_name_with_many_params = function(p1, p2, p3)  # Long but acceptable
```

### GDScript
```gdscript
# Tab indentation (project standard)
if condition:
	do_something()  # 1 tab from line above

# Spacing similar to Python
var x = 10
var result = a + b

# Method spacing
func method_name() -> ReturnType:
	# Implementation
	pass
```

---

## File Organization

### Python File Structure
```python
#!/usr/bin/env python3
"""Module docstring explaining purpose."""

# Imports (in order: stdlib, third-party, local)
import sys
from pathlib import Path

# Constants
MAX_VALUE = 100

# Classes
class MyClass:
    pass

# Functions (if any)
def my_function():
    pass

# Main execution
if __name__ == "__main__":
    pass
```

### Folder Structure
```
python_backup/          # Python systems
├── backup_system.py    # Main interface
├── problem_generator.py
├── score_manager.py
├── config_manager.py
├── teacher_mode.py
└── README.md

scripts/                # GDScript systems
├── game_manager.gd
├── main_menu.gd
├── system_manager.gd
└── ...
```

---

## Common Patterns

### Difficulty Ranges (Cached for Performance)
```python
DIFFICULTY_RANGES = {
    "EASY": {"min": 1, "max": 10},
    "MEDIUM": {"min": 1, "max": 50},
    "HARD": {"min": 1, "max": 100},
}
```

### Boolean Variables (Clear naming)
```python
is_available = True
has_teacher_mode = False
can_generate = True
should_continue = False
```

### Error Handling (Consistent pattern)
```python
try:
    result = operation()
    return result
except SpecificException as e:
    print(f"ERROR: Operation failed: {e}")
    return None
except Exception as e:
    print(f"WARNING: Unexpected error: {e}")
    return fallback_value
```

### Private vs Public (Clear separation)
```python
# Public interface
def generate_problem(self):
    pass

# Private helpers (underscore prefix)
def _calculate_answer(self):
    pass

# Public attributes
self.score = 0

# Private attributes (underscore prefix)
self._cache_size = 5
```

---

## Length Guidelines

### Variable Names
- **Minimum**: 3+ characters (except `i` in loops)
- **Typical**: 3-4 words total
- **Maximum**: As long as needed for clarity

### Function Names
- **Minimum**: 2-3 words
- **Typical**: 2-4 words
- **Maximum**: As long as needed for clarity

### Line Length
- **Target**: 80-100 characters
- **Absolute max**: 120 characters
- Break long lines with parentheses or backslash

### Comments
- **Inline**: 1-2 lines usually
- **Block**: 3-10 lines for complex logic
- **Docstring**: As long as needed, structured

---

## Decision Flowchart

**Should I add a comment?**

```
Is it obvious from reading the code?
├─ YES → Don't comment
└─ NO → Is it complex logic or non-obvious decision?
	├─ YES → Add comment explaining WHY
	└─ NO → Maybe improve variable/function names instead
```

**What should I name this?**

```
Is it a function/method?
├─ YES → Use action verb (generate, save, load, check)
└─ NO → Is it a boolean?
	├─ YES → Use is_/has_/can_/should_ prefix
	└─ NO → Use descriptive noun phrase (3-4 words)
```

**Should this be private or public?**

```
Is this part of the public API?
├─ YES → public (no prefix)
└─ NO → Should it be hidden from users?
	└─ YES → private (_prefix)
```

---

## Common Mistakes to Avoid

| Mistake | Example | Fix |
|---------|---------|-----|
| Unclear abbreviations | `ps`, `mdr`, `gen` | `player_score`, `max_difficulty`, `generator` |
| Single-letter vars | `x`, `y`, `t` (except `i`, `j` in loops) | `operand1`, `timestamp`, `total` |
| Comment explains WHAT | `# Add 1 to x` | `# Increment counter for next item` |
| Dead commented code | `# x = old_calculation()` | Remove it |
| Inconsistent style | Mix of snake_case and camelCase | Use snake_case consistently |
| No docstrings | `def func():` | Add docstring |
| Too vague names | `do_something()`, `process()` | `generate_problem()`, `save_score()` |
| Boolean ambiguity | `enabled = True` | `is_enabled = True` |

---

## Quick Checklist

Before submitting code:

- [ ] Function names are verbs or verb phrases
- [ ] Variable names are 3+ characters, descriptive
- [ ] Boolean variables use is_/has_/can_/should_
- [ ] All public functions have docstrings
- [ ] Comments explain WHY not WHAT
- [ ] Private methods/vars use _ prefix
- [ ] Constants are UPPER_SNAKE_CASE
- [ ] Indentation is consistent (4 spaces Python, tabs GDScript)
- [ ] No dead or commented code
- [ ] Line lengths reasonable (~100 chars target)

---

## Where to Find Full Details

- **Naming Conventions**: CODE_STANDARDS.md - "Naming Conventions" section
- **Docstring Format**: CODE_STANDARDS.md - "Comments and Documentation" section  
- **Examples**: CODE_STANDARDS.md - "Examples: Before and After" section
- **Python Specific**: CODE_STANDARDS.md - "Python Code Standards" section
- **GDScript Specific**: CODE_STANDARDS.md - "GDScript Code Standards" section
- **File Organization**: CODE_STANDARDS.md - "File Organization" section

---

## Remember

> Code is read much more often than it's written. Make it easy for others (and future you) to understand.

**Key Principle**: **Clear Names > Comments** (but both are good!)

Good naming reduces need for comments.  
Good comments explain important decisions.  
Together, they make great code.

---

**Version**: 1.0  
**Updated**: 2026-01-20

See [CODE_STANDARDS.md](CODE_STANDARDS.md) for complete reference.
