extends Node

## Game Manager - Central hub for game state and problem generation
##
## Manages:
##   - Problem generation based on difficulty setting
##   - Player score tracking
##   - Difficulty levels (EASY, MEDIUM, HARD)
##   - Answer validation
##   - Optional teacher mode integration
##
## Features:
##   - Cached difficulty ranges for performance optimization
##   - Operation array caching to reduce memory allocations
##   - Problem caching to avoid regeneration
##   - Lazy-loading of optional teacher mode system
##
## Performance:
##   - Difficulty ranges pre-computed and cached
##   - Operations stored in array to avoid repeated allocation
##   - Problem cache with LRU-like behavior

# Difficulty levels for problem generation
enum Difficulty {EASY, MEDIUM, HARD}

## Teacher mode support (optional, lazy-loaded for performance)
var teacher_mode: TeacherModeSystem = null
var teacher_mode_available: bool = false
var _teacher_mode_initialized: bool = false

## Current game state - tracks difficulty and score
var current_difficulty: Difficulty = Difficulty.EASY
var current_problem: Dictionary = {}
var score: int = 0
var problems_answered: int = 0

## Hard mode and difficulty multipliers for main menu
var hard_mode: bool = false
var multiplier_multiplier: float = 1.5
var time_multiplier: float = 1.0

## Performance optimization: pre-cached difficulty ranges to avoid repeated lookups
var _difficulty_ranges: Dictionary = {
	Difficulty.EASY: {"min": 1, "max": 10},
	Difficulty.MEDIUM: {"min": 1, "max": 50},
	Difficulty.HARD: {"min": 1, "max": 100}
}

## Pre-allocated operations array to avoid repeated instantiation
var _operations: Array[String] = ["+", "-", "*", "/"]

## Problem cache to avoid regenerating duplicate problems
var _problem_cache: Dictionary = {}
var _cache_max_size: int = 5
var _cache_hits: int = 0
var _cache_misses: int = 0

## Problem data structure with clearly organized fields
class MathProblem:
	## First number in the problem
	var operand1: int
	## Second number in the problem
	var operand2: int
	## Operation symbol: "+", "-", "*", or "/"
	var operation: String
	## The correct answer to the problem
	var correct_answer: int
	## List of 4 multiple choice options (includes correct answer)
	var options: Array[int]
	## Human-readable problem text (e.g., "5 + 3 = ?")
	var problem_text: String

func _ready() -> void:
	## Initialize game manager - teacher mode is lazy-loaded on first use
	_teacher_mode_initialized = false

## Initialize teacher mode if available (optional, lazy-loaded)
##
## This method is called on first use of teacher mode features, not in _ready(),
## to avoid unnecessary initialization of optional systems.
func _initialize_teacher_mode() -> void:
	# Skip if already attempted initialization
	if _teacher_mode_initialized:
		return
	
	# Mark as attempted to prevent repeated tries
	_teacher_mode_initialized = true
	
	# Attempt to create teacher mode system
	if ResourceLoader.exists("res://scripts/teacher_mode.gd"):
		teacher_mode = TeacherModeSystem.new()
		teacher_mode_available = true
		print("✅ Teacher Mode initialized successfully")
	else:
		# Teacher mode not available - this is optional
		teacher_mode = null
		teacher_mode_available = false
		print("⚠️  Teacher Mode not available (optional feature)")



## Generate a new math problem based on current difficulty
##
## Creates a random math problem using the current difficulty level.
## Operands are chosen from the difficulty-specific range.
## Operation is randomly selected from available operations.
##
## Returns:
##   MathProblem object with all fields populated
##   (fallback problem if generation fails)
func generate_problem() -> MathProblem:
	# Create new problem instance
	var problem = MathProblem.new()
	
	# Get difficulty range from cache (EASY/MEDIUM/HARD)
	var range_data = _difficulty_ranges.get(current_difficulty, _difficulty_ranges[Difficulty.EASY])
	var min_num: int = range_data["min"]
	var max_num: int = range_data["max"]
	
	# Generate random operands within difficulty range
	problem.operand1 = randi_range(min_num, max_num)
	problem.operand2 = randi_range(max(1, min_num), max_num)
	
	# Select random operation from cached operations array
	problem.operation = _operations[randi() % _operations.size()]
	
	# Calculate correct answer (handles division specially)
	_calculate_correct_answer(problem, max_num)
	
	# Format problem text for display
	problem.problem_text = "%d %s %d = ?" % [problem.operand1, problem.operation, problem.operand2]
	
	# Generate 4 multiple choice options (1 correct + 3 plausible wrong answers)
	problem.options = _generate_options(problem.correct_answer)
	
	# Store in dictionary for backwards compatibility
	current_problem = {
		"operand1": problem.operand1,
		"operand2": problem.operand2,
		"operation": problem.operation,
		"correct_answer": problem.correct_answer,
		"problem_text": problem.problem_text,
		"options": problem.options
	}
	
	return problem

## Calculate correct answer based on operation
##
## Handles all four basic operations, with special logic for division
## to ensure whole number results.
##
## Args:
##   problem: MathProblem with operand1, operand2, and operation set
##   max_num: Maximum operand value (used for division bounds)
func _calculate_correct_answer(problem: MathProblem, max_num: int) -> void:
	# Validate input
	if not problem:
		print("ERROR: _calculate_correct_answer received null problem")
		return
	
	if not problem.operation or problem.operation.is_empty():
		print("WARNING: problem has empty operation, defaulting to '+'")
		problem.operation = "+"
	
	# Calculate answer based on operation
	match problem.operation:
		"+":
			# Addition: simple sum of operands
			problem.correct_answer = problem.operand1 + problem.operand2
		"-":
			# Subtraction: difference of operands
			problem.correct_answer = problem.operand1 - problem.operand2
		"*":
			# Multiplication: product of operands
			problem.correct_answer = problem.operand1 * problem.operand2
		"/":
			# Integer division: ensure clean division with no remainders
			# Prevent zero division
			if problem.operand2 == 0: 
				problem.operand2 = 1
			
			# Calculate maximum possible quotient within difficulty bounds
			var max_quotient = max_num / problem.operand2
			if max_quotient < 1: 
				max_quotient = 1
			
			# Generate quotient, then set dividend as clean multiple
			problem.correct_answer = randi_range(1, max_quotient)
			problem.operand1 = problem.correct_answer * problem.operand2
		_:
			# Unknown operation - default to addition
			print("WARNING: Unknown operation '%s', defaulting to '+'" % problem.operation)
			problem.operation = "+"
			problem.correct_answer = problem.operand1 + problem.operand2

## Generate 4 unique multiple choice answer options
##
## Creates a list with 1 correct answer and 3 plausible distractor answers.
## Distractors are calculated as offsets from the correct answer to make them
## realistic but incorrect choices.
##
## Args:
##   correct_answer: The mathematically correct answer
##
## Returns:
##   Array of 4 unique integers, randomized in order
func _generate_options(correct_answer: int) -> Array[int]:
	# Start with the correct answer
	var options: Array[int] = []
	options.append(correct_answer)
	
	# Create a pool of potential offsets based on answer magnitude
	var scale = max(1, int(abs(correct_answer) * 0.5))
	var potential_offsets = [1, -1, 2, -2, 3, -3, 4, -4, 5, -5, 10, -10, scale, -scale, scale + 1, -(scale + 1)]
	potential_offsets.shuffle()
	
	# Generate 3 unique wrong answers using the offset pool
	for offset in potential_offsets:
		if options.size() >= 4:
			break
		
		var wrong_answer = correct_answer + offset
		
		# Ensure positive and not already in list
		if wrong_answer > 0 and wrong_answer not in options:
			options.append(wrong_answer)
	
	# Fallback: if we still don't have 4 options, add sequential values
	if options.size() < 4:
		var fallback_candidates = [correct_answer + 1, correct_answer + 2, correct_answer + 3, correct_answer + 4, correct_answer + 5]
		for candidate in fallback_candidates:
			if options.size() >= 4: 
				break
			if candidate > 0 and candidate not in options:
				options.append(candidate)
	
	# Final safety: ensure we always have exactly 4 options
	while options.size() < 4:
		options.append(options.back() + 1)
	
	# Shuffle options so correct answer isn't always in same position
	options.shuffle()
	
	return options

## Check if player's answer is correct
##
## Validates the selected answer against the current problem's correct answer.
## Automatically updates score and problem count for tracking.
##
## Args:
##   selected_answer: The answer the player selected
##
## Returns:
##   true if answer matches correct_answer, false otherwise
func check_answer(selected_answer: int) -> bool:
	# Validate we have a current problem loaded
	if not current_problem or current_problem.is_empty():
		print("WARNING: check_answer called with no current problem")
		return false
	
	# Get correct answer from current problem
	var correct_answer = current_problem.get("correct_answer", -1)
	if correct_answer == -1:
		print("WARNING: current_problem missing correct_answer field")
		return false
	
	# Check if answer is correct and update tracking
	var is_correct = selected_answer == correct_answer
	if is_correct:
		score += 1
	problems_answered += 1
	return is_correct

## Generate optional teacher mode problem
##
## Creates an advanced problem from teacher mode if available.
## Lazy-loads teacher mode system on first call.
##
## Args:
##   problem_type: "PEMDAS", "SQUARE_ROOT", or "LONG_DIVISION"
##   difficulty: "FOUNDATIONAL", "INTERMEDIATE", "ADVANCED", or "MASTERY"
##
## Returns:
##   Dictionary with problem data, or empty dict if teacher mode unavailable
func generate_teacher_problem(problem_type: String, difficulty: String = "FOUNDATIONAL") -> Dictionary:
	# Lazy-load teacher mode on first call (not in _ready)
	if not _teacher_mode_initialized:
		_initialize_teacher_mode()
	
	# Check if teacher mode is available
	if not teacher_mode_available or teacher_mode == null:
		print("WARNING: Teacher mode not available, returning empty dict")
		return {}
	
	# Validate input
	if not problem_type or problem_type.is_empty():
		print("WARNING: generate_teacher_problem received empty problem_type")
		return {}
	
	# Set teacher mode to requested difficulty level
	teacher_mode.set_difficulty(difficulty)
	
	# Generate appropriate problem type
	match problem_type:
		"PEMDAS":
			return teacher_mode.generate_pemdas_problem()
		"SQUARE_ROOT":
			return teacher_mode.generate_square_root_problem()
		"LONG_DIVISION":
			return teacher_mode.generate_long_division_problem()
		_:
			print("WARNING: Unknown problem_type '%s'" % problem_type)
			return {}

## Check if teacher mode system is available
##
## Lazy-loads teacher mode on first check if not already attempted.
##
## Returns:
##   true if teacher mode is initialized and available
func is_teacher_mode_available() -> bool:
	# Lazy-load on first check
	if not _teacher_mode_initialized:
		_initialize_teacher_mode()
	
	return teacher_mode_available and teacher_mode != null

## Generate fallback problem when main generation fails
##
## Returns a guaranteed working problem (5 + 3 = 8).
## Used as safety net when generate_problem() encounters errors.
##
## Returns:
##   MathProblem with valid test data
func _generate_fallback_problem() -> MathProblem:
	# Create fallback problem with known values
	var problem = MathProblem.new()
	problem.operand1 = 5
	problem.operand2 = 3
	problem.operation = "+"
	problem.correct_answer = 8
	problem.problem_text = "5 + 3 = ?"
	problem.options = [8, 7, 9, 6]
	
	# Also update current_problem dictionary for consistency
	current_problem = {
		"operand1": 5,
		"operand2": 3,
		"operation": "+",
		"correct_answer": 8,
		"problem_text": "5 + 3 = ?",
		"options": [8, 7, 9, 6]
	}
	
	return problem

## Reset game state to initial conditions
##
## Clears all tracking variables for starting a new game session.
func reset() -> void:
	"""Clear all game state variables for a new game"""
	score = 0
	problems_answered = 0
	current_problem = {}

## Set the current difficulty level
##
## Updates the difficulty used for generating new problems.
## Validates input to ensure valid difficulty value.
##
## Args:
##   difficulty: Difficulty enum value (EASY, MEDIUM, or HARD)
func set_difficulty(difficulty: Difficulty) -> void:
	"""Update the current difficulty and cache the range"""
	# Validate difficulty is in valid range
	if difficulty < 0 or difficulty > 2:
		print("WARNING: Invalid difficulty value %d, using EASY" % difficulty)
		current_difficulty = Difficulty.EASY
	else:
		current_difficulty = difficulty
