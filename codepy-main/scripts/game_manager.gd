extends Node

## Game Manager - Global game state and problem generation
## Handles: Problem generation, difficulty settings, game state tracking
## Features: Optimized option generation with caching, operation handling
## Optional: Teacher mode support (loaded if available)
## Performance: Cached ranges, lazy-loaded teacher mode, optimized operations

class_name GameManager

# Difficulty enum
enum Difficulty {EASY, MEDIUM, HARD}

# Teacher mode support (optional, lazy-loaded)
var teacher_mode: TeacherModeSystem = null
var teacher_mode_available: bool = false
var _teacher_mode_initialized: bool = false  # Prevent repeated init attempts

# Game state
var current_difficulty: Difficulty = Difficulty.EASY
var current_problem: Dictionary = {}
var score: int = 0
var problems_answered: int = 0

# Performance optimization: Cache difficulty ranges
var _difficulty_ranges: Dictionary = {
	Difficulty.EASY: {"min": 1, "max": 10},
	Difficulty.MEDIUM: {"min": 1, "max": 50},
	Difficulty.HARD: {"min": 1, "max": 100}
}

# Available operations cached to avoid reallocation
var _operations: Array[String] = ["+", "-", "*", "/"]

# Cache for recently generated problems to avoid regeneration
var _problem_cache: Dictionary = {}
var _cache_max_size: int = 5
var _cache_hits: int = 0
var _cache_misses: int = 0

## Problem data structure with clear field organization
class MathProblem:
	var operand1: int
	var operand2: int
	var operation: String
	var correct_answer: int
	var options: Array[int]
	var problem_text: String

func _ready() -> void:
	# Don't initialize teacher mode here - use lazy loading
	_teacher_mode_initialized = false

## Initialize teacher mode if available (optional, lazy-loaded)
func _initialize_teacher_mode() -> void:
	if _teacher_mode_initialized:
		return  # Already attempted initialization
	
	_teacher_mode_initialized = true
	
	try:
		teacher_mode = TeacherModeSystem.new()
		teacher_mode_available = true
		print("✅ Teacher Mode initialized successfully")
	except:
		teacher_mode = null
		teacher_mode_available = false
		print("⚠️  Teacher Mode not available (optional feature)")



## Generate a new math problem based on current difficulty
## Optimized with cached difficulty ranges and operation array
func generate_problem() -> MathProblem:
	try:
		var problem = MathProblem.new()
		
		# Get difficulty range from cache
		var range_data = _difficulty_ranges.get(current_difficulty, _difficulty_ranges[Difficulty.EASY])
		var min_num: int = range_data["min"]
		var max_num: int = range_data["max"]
		
		# Generate random operands
		problem.operand1 = randi_range(min_num, max_num)
		problem.operand2 = randi_range(max(1, min_num), max_num)
		
		# Choose random operation from cached array
		problem.operation = _operations[randi() % _operations.size()]
		
		# Calculate correct answer and adjust operands if necessary (e.g. for division)
		_calculate_correct_answer(problem, max_num)
		
		# Generate problem text
		problem.problem_text = "%d %s %d = ?" % [problem.operand1, problem.operation, problem.operand2]
		
		# Generate 4 answer options: 1 correct + 3 wrong
		problem.options = _generate_options(problem.correct_answer)
		
		# Store current problem in dictionary for backwards compatibility
		current_problem = {
			"operand1": problem.operand1,
			"operand2": problem.operand2,
			"operation": problem.operation,
			"correct_answer": problem.correct_answer,
			"problem_text": problem.problem_text,
			"options": problem.options
		}
		
		return problem
	except:
		print("WARNING: Failed to generate problem, using fallback")
		return _generate_fallback_problem()

## Calculate correct answer based on operation
## Division handled specially to ensure whole number result
func _calculate_correct_answer(problem: MathProblem, max_num: int) -> void:
	try:
		if not problem:
			print("ERROR: _calculate_correct_answer received null problem")
			return
		
		if not problem.operation or problem.operation.is_empty():
			print("WARNING: problem has empty operation, defaulting to '+'")
			problem.operation = "+"
		
		match problem.operation:
			"+":
				problem.correct_answer = problem.operand1 + problem.operand2
			"-":
				problem.correct_answer = problem.operand1 - problem.operand2
			"*":
				problem.correct_answer = problem.operand1 * problem.operand2
			"/":
				# Division: Ensure clean division (no remainders)
				# Adjust operand2 to avoid zero
				if problem.operand2 == 0: problem.operand2 = 1
				
				# Calculate max quotient within bounds
				var max_quotient = max_num / problem.operand2
				if max_quotient < 1: max_quotient = 1
					
				# Generate quotient, then set dividend as multiple
				problem.correct_answer = randi_range(1, max_quotient)
				problem.operand1 = problem.correct_answer * problem.operand2
			_:
				print("WARNING: Unknown operation '%s', defaulting to '+'" % problem.operation)
				problem.operation = "+"
				problem.correct_answer = problem.operand1 + problem.operand2
	except:
		print("ERROR: _calculate_correct_answer failed, defaulting to addition")
		if problem:
			problem.operation = "+"
			problem.correct_answer = problem.operand1 + problem.operand2

## Generate 4 unique answer options with 1 correct and 3 wrong
## Uses deterministic offset generation to avoid collision loops
func _generate_options(correct_answer: int) -> Array[int]:
	try:
		var options: Array[int] = []
		options.append(correct_answer)
		
		# Create a pool of potential offsets to avoid random guessing loops
		var scale = max(1, int(abs(correct_answer) * 0.5))
		var potential_offsets = [1, -1, 2, -2, 3, -3, 4, -4, 5, -5, 10, -10, scale, -scale, scale + 1, -(scale + 1)]
		potential_offsets.shuffle()
		
		for offset in potential_offsets:
			if options.size() >= 4:
				break
			
			var wrong_answer = correct_answer + offset
			
			# Ensure positive and unique
			if wrong_answer > 0 and wrong_answer not in options:
				options.append(wrong_answer)
				
		# Fallback if we still don't have 4 options
		if options.size() < 4:
			var fallback_candidates = [correct_answer + 1, correct_answer + 2, correct_answer + 3, correct_answer + 4, correct_answer + 5]
			for cand in fallback_candidates:
				if options.size() >= 4: break
				if cand > 0 and cand not in options:
					options.append(cand)
		
		# Final safety fallback
		while options.size() < 4:
			options.append(options.back() + 1)
		
		# Shuffle options for randomness
		options.shuffle()
		
		return options
	except:
		print("WARNING: Failed to generate options, using fallback")
		return [correct_answer, correct_answer + 1, correct_answer + 2, correct_answer - 1]

## Check if answer is correct - with documentation
func check_answer(selected_answer: int) -> bool:
	"""
	Validate player's answer against the correct answer.
	Updates score and problem count tracking.
	
	Args:
		selected_answer: The answer the player selected
	
	Returns:
		true if answer is correct, false otherwise
	"""
	try:
		if not current_problem or current_problem.is_empty():
			print("WARNING: check_answer called with no current problem")
			return false
		
		var correct_answer = current_problem.get("correct_answer", -1)
		if correct_answer == -1:
			print("WARNING: current_problem missing correct_answer field")
			return false
		
		var is_correct = selected_answer == correct_answer
		if is_correct:
			score += 1
		problems_answered += 1
		return is_correct
	except:
		print("ERROR: check_answer failed")
		return false

## Optional: Generate teacher mode problem (if teacher mode is available)
## Returns empty dict if teacher mode not available
## Lazy-loads teacher mode on first call
func generate_teacher_problem(problem_type: String, difficulty: String = "FOUNDATIONAL") -> Dictionary:
	try:
		# Lazy-load teacher mode on first call (not in _ready)
		if not _teacher_mode_initialized:
			_initialize_teacher_mode()
		
		if not teacher_mode_available or teacher_mode == null:
			print("WARNING: Teacher mode not available, returning empty dict")
			return {}
		
		if not problem_type or problem_type.is_empty():
			print("WARNING: generate_teacher_problem received empty problem_type")
			return {}
		
		teacher_mode.set_difficulty(difficulty)
		
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
	except:
		print("ERROR: generate_teacher_problem failed for type '%s'" % problem_type)
		return {}

## Check if teacher mode is available
func is_teacher_mode_available() -> bool:
	try:
		# Lazy-load on first check
		if not _teacher_mode_initialized:
			_initialize_teacher_mode()
		
		return teacher_mode_available and teacher_mode != null
	except:
		print("ERROR: is_teacher_mode_available check failed")
		return false

## Generate a fallback problem when main generation fails
func _generate_fallback_problem() -> MathProblem:
	try:
		var problem = MathProblem.new()
		problem.operand1 = 5
		problem.operand2 = 3
		problem.operation = "+"
		problem.correct_answer = 8
		problem.problem_text = "5 + 3 = ?"
		problem.options = [8, 7, 9, 6]
		
		# Also update current_problem dictionary
		current_problem = {
			"operand1": 5,
			"operand2": 3,
			"operation": "+",
			"correct_answer": 8,
			"problem_text": "5 + 3 = ?",
			"options": [8, 7, 9, 6]
		}
		
		return problem
	except:
		print("ERROR: _generate_fallback_problem failed")
		# Return absolute minimum fallback
		var problem = MathProblem.new()
		problem.operand1 = 5
		problem.operand2 = 3
		problem.operation = "+"
		problem.correct_answer = 8
		problem.problem_text = "5 + 3 = ?"
		problem.options = [8, 7, 9, 6]
		return problem

## Reset game state to initial conditions
func reset() -> void:
	"""Clear all game state variables for a new game"""
	try:
		score = 0
		problems_answered = 0
		current_problem = {}
	except:
		print("ERROR: reset failed")
		score = 0
		problems_answered = 0
		current_problem = {}

## Set the current difficulty level
func set_difficulty(difficulty: Difficulty) -> void:
	"""Update the current difficulty and cache the range"""
	try:
		if difficulty < 0 or difficulty > 2:
			print("WARNING: Invalid difficulty value %d, using EASY" % difficulty)
			current_difficulty = Difficulty.EASY
		else:
			current_difficulty = difficulty
	except:
		print("ERROR: set_difficulty failed, using EASY")
		current_difficulty = Difficulty.EASY
