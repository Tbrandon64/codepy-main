extends Node

# Difficulty enum
enum Difficulty {EASY, MEDIUM, HARD}

# Game state
var current_difficulty: Difficulty = Difficulty.EASY
var current_problem: Dictionary = {}
var score: int = 0
var problems_answered: int = 0

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
func generate_problem() -> MathProblem:
	var problem = MathProblem.new()
	var min_num: int
	var max_num: int
	
	# Set number range based on difficulty
	match current_difficulty:
		Difficulty.EASY:
			min_num = 1
			max_num = 10
		Difficulty.MEDIUM:
			min_num = 1
			max_num = 50
		Difficulty.HARD:
			min_num = 1
			max_num = 100
		_:
			min_num = 1
			max_num = 10
	
	# Generate random operands
	problem.operand1 = randi_range(min_num, max_num)
	problem.operand2 = randi_range(max(1, min_num), max_num)
	
	# Choose random operation
	var operations = ["+", "-", "*", "/"]
	problem.operation = operations[randi() % operations.size()]
	
	# Calculate correct answer
	match problem.operation:
		"+":
			problem.correct_answer = problem.operand1 + problem.operand2
		"-":
			problem.correct_answer = problem.operand1 - problem.operand2
		"*":
			problem.correct_answer = problem.operand1 * problem.operand2
		"/":
			# Ensure integer division - adjust operand2 to divide evenly
			while problem.operand1 % problem.operand2 != 0:
				problem.operand2 = randi_range(1, max_num)
				if problem.operand2 == 0:
					problem.operand2 = 1
			problem.correct_answer = problem.operand1 / problem.operand2
	
	# Generate problem text
	problem.problem_text = "%d %s %d = ?" % [problem.operand1, problem.operation, problem.operand2]
	
	# Generate 4 answer options: 1 correct + 3 wrong
	problem.options = _generate_options(problem.correct_answer)
	
	# Store current problem
	current_problem = {
		"operand1": problem.operand1,
		"operand2": problem.operand2,
		"operation": problem.operation,
		"correct_answer": problem.correct_answer,
		"problem_text": problem.problem_text,
		"options": problem.options
	}
	
	return problem

## Generate 4 unique answer options with 1 correct and 3 wrong
func _generate_options(correct_answer: int) -> Array[int]:
	var options: Array[int] = []
	options.append(correct_answer)
	
	# Generate 3 wrong answers by applying random offsets
	var attempts = 0
	while options.size() < 4 and attempts < 50:
		var offset = randi_range(1, max(5, abs(correct_answer)))
		
		# Randomly choose to add or subtract (ensure positive result)
		if randi() % 2 == 0:
			var wrong_answer = correct_answer + offset
			if wrong_answer > 0 and wrong_answer not in options:
				options.append(wrong_answer)
		else:
			var wrong_answer = correct_answer - offset
			if wrong_answer > 0 and wrong_answer not in options:
				options.append(wrong_answer)
		
		attempts += 1
	
	# Shuffle options
	options.shuffle()
	
	return options

## Check if answer is correct
func check_answer(selected_answer: int) -> bool:
	var is_correct = selected_answer == current_problem.get("correct_answer", -1)
	if is_correct:
		score += 1
	problems_answered += 1
	return is_correct

## Reset game state
func reset() -> void:
	score = 0
	problems_answered = 0
	current_problem = {}

## Set difficulty
func set_difficulty(difficulty: Difficulty) -> void:
	current_difficulty = difficulty
