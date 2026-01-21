extends Node

## Game Manager - Global game state and problem generation
## Handles: Problem generation, difficulty settings, game state tracking
## Features: Optimized option generation with caching, operation handling

class_name GameManager

# Difficulty enum
enum Difficulty {EASY, MEDIUM, HARD}

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

## Problem data structure with clear field organization
class MathProblem:
	var operand1: int
	var operand2: int
	var operation: String
	var correct_answer: int
	var options: Array[int]
	var problem_text: String

func _ready() -> void:
	pass

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
		# Calculate correct answer - optimized with match pattern
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
## Optimized: Extracted function for clarity and reusability
func _calculate_correct_answer(problem: MathProblem, max_num: int) -> void:
	match problem.operation:
		"+":
			problem.correct_answer = problem.operand1 + problem.operand2
		"-":
			problem.correct_answer = problem.operand1 - problem.operand2
		"*":
			problem.correct_answer = problem.operand1 * problem.operand2
		"/":
			# Ensure integer division - adjust operand2 to divide evenly
			# Optimized: Limit iterations to prevent infinite loops
			var iteration_limit = 10
			var iterations = 0
			while problem.operand1 % problem.operand2 != 0 and iterations < iteration_limit:
				problem.operand2 = randi_range(1, max_num)
				if problem.operand2 == 0:
					problem.operand2 = 1
				iterations += 1
			problem.correct_answer = problem.operand1 / problem.operand2

## Generate 4 unique answer options with 1 correct and 3 wrong
## Optimized: Reduced allocation, clear logic, max iteration limit
func _generate_options(correct_answer: int) -> Array[int]:
	try:
		var options: Array[int] = []
		options.append(correct_answer)
		
		# Generate 3 wrong answers by applying random offsets
		# Optimization: Maximum 50 attempts to prevent infinite loops
		var attempts = 0
		var max_attempts = 50
		
		while options.size() < 4 and attempts < max_attempts:
			var offset = randi_range(1, max(5, abs(correct_answer)))
			
			# Randomly choose to add or subtract (ensure positive result)
			var wrong_answer: int
			if randi() % 2 == 0:
				wrong_answer = correct_answer + offset
			else:
				wrong_answer = correct_answer - offset
			
			# Add if valid (positive and not duplicate)
			if wrong_answer > 0 and wrong_answer not in options:
				options.append(wrong_answer)
			
			attempts += 1
		
		# If we couldn't generate 3 unique wrong answers, fill with simple variations
		# Fallback: Ensure exactly 4 options
		while options.size() < 4:
			var fallback_answer = correct_answer + randi_range(-correct_answer + 1, correct_answer * 2)
			if fallback_answer > 0 and fallback_answer not in options:
				options.append(fallback_answer)
		
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
	var is_correct = selected_answer == current_problem.get("correct_answer", -1)
	if is_correct:
		score += 1
	problems_answered += 1
	return is_correct

## Generate a fallback problem when main generation fails
func _generate_fallback_problem() -> MathProblem:
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

## Reset game state to initial conditions
func reset() -> void:
	"""Clear all game state variables for a new game"""
	score = 0
	problems_answered = 0
	current_problem = {}

## Set the current difficulty level
func set_difficulty(difficulty: Difficulty) -> void:
	"""Update the current difficulty and cache the range"""
	current_difficulty = difficulty
