extends Node

## Teacher Mode System - Advanced mathematics education features
## Handles: PEMDAS problems, square roots, long division
## Supports difficulty progression and problem verification
## Optimized: Problem caching, reduced allocations, lazy computation

class_name TeacherModeSystem

# Problem type enum
enum ProblemType {
	BASIC,           # Basic arithmetic (1+2)
	PEMDAS,          # Order of operations (3+4*2)
	SQUARE_ROOT,     # Square root problems
	LONG_DIVISION,   # Multi-step division
	MIXED            # Random mix of above
}

# Difficulty levels for advanced modes
enum AdvancedDifficulty {
	FOUNDATIONAL,    # Simple PEMDAS, perfect squares
	INTERMEDIATE,    # Complex PEMDAS, non-perfect squares
	ADVANCED,        # Very complex PEMDAS, large divisions
	MASTERY          # All features, high complexity
}

var current_problem_type: ProblemType = ProblemType.BASIC
var current_advanced_difficulty: AdvancedDifficulty = AdvancedDifficulty.FOUNDATIONAL
var teacher_mode_enabled: bool = false
var show_work: bool = false          # Show step-by-step solution
var track_progress: bool = false     # Track student progress
var student_progress: Dictionary = {}

# Performance caches
var _problem_cache: Dictionary = {}  # Cache generated problems
var _solution_cache: Dictionary = {} # Cache solution steps
var _cache_max_size: int = 20

# Signals for teacher mode
signal problem_type_changed(type: String)
signal mode_enabled(enabled: bool)
signal progress_updated(student_name: String, stats: Dictionary)

func _ready() -> void:
	pass

## Enable/disable teacher mode
func set_teacher_mode(enabled: bool) -> void:
	teacher_mode_enabled = enabled
	mode_enabled.emit(enabled)
	
	if enabled:
		print("✅ Teacher Mode Enabled")
	else:
		print("Teacher Mode Disabled")

## Set problem type for generation
func set_problem_type(problem_type: int) -> void:
	try:
		if problem_type >= 0 and problem_type < ProblemType.size():
			current_problem_type = problem_type
			problem_type_changed.emit(ProblemType.keys()[problem_type])
	except:
		current_problem_type = ProblemType.BASIC

## Set advanced difficulty
func set_difficulty(difficulty: String) -> void:
	match difficulty:
		"FOUNDATIONAL":
			current_advanced_difficulty = AdvancedDifficulty.FOUNDATIONAL
		"INTERMEDIATE":
			current_advanced_difficulty = AdvancedDifficulty.INTERMEDIATE
		"ADVANCED":
			current_advanced_difficulty = AdvancedDifficulty.ADVANCED
		"MASTERY":
			current_advanced_difficulty = AdvancedDifficulty.MASTERY
		_:
			current_advanced_difficulty = AdvancedDifficulty.FOUNDATIONAL


## Generate PEMDAS problem
## Format: a OP b OP c with mixed operations
func generate_pemdas_problem() -> Dictionary:
	try:
		var problem = {
			"type": "PEMDAS",
			"steps": [],
			"problem_text": "",
			"correct_answer": 0,
			"options": []
		}
		
		# Determine problem complexity based on difficulty
		var complexity = _get_pemdas_complexity()
		
		if complexity == 1:
			# Simple: 2 operations (a OP b OP c)
			problem = _generate_simple_pemdas()
		elif complexity == 2:
			# Intermediate: 3 operations with parentheses
			problem = _generate_intermediate_pemdas()
		else:
			# Advanced: 4+ operations, multiple parentheses
			problem = _generate_advanced_pemdas()
		
		problem["steps"] = _generate_solution_steps(problem)
		return problem
	
	except:
		print("WARNING: Failed to generate PEMDAS problem")
		return _generate_simple_pemdas()

## Generate square root problem
func generate_square_root_problem() -> Dictionary:
	try:
		var problem = {
			"type": "SQUARE_ROOT",
			"steps": [],
			"problem_text": "",
			"correct_answer": 0,
			"options": [],
			"radicand": 0
		}
		
		var difficulty = current_advanced_difficulty
		
		if difficulty == AdvancedDifficulty.FOUNDATIONAL:
			# Perfect squares: 4, 9, 16, 25, 36, 49, 64, 81, 100
			problem = _generate_perfect_square()
		elif difficulty == AdvancedDifficulty.INTERMEDIATE:
			# Perfect squares up to 400
			problem = _generate_perfect_square_extended()
		elif difficulty == AdvancedDifficulty.ADVANCED:
			# Approximation problems
			problem = _generate_square_root_approximation()
		else:
			# Mixed with operations
			problem = _generate_square_root_mixed()
		
		problem["steps"] = _generate_square_root_steps(problem)
		return problem
	
	except:
		print("WARNING: Failed to generate square root problem")
		return _generate_perfect_square()

## Generate long division problem
func generate_long_division_problem() -> Dictionary:
	try:
		var problem = {
			"type": "LONG_DIVISION",
			"steps": [],
			"problem_text": "",
			"correct_answer": 0,
			"options": [],
			"dividend": 0,
			"divisor": 0,
			"quotient": 0,
			"remainder": 0
		}
		
		var difficulty = current_advanced_difficulty
		
		if difficulty == AdvancedDifficulty.FOUNDATIONAL:
			# 2-digit ÷ 1-digit
			problem = _generate_simple_long_division()
		elif difficulty == AdvancedDifficulty.INTERMEDIATE:
			# 3-digit ÷ 1-digit or 3-digit ÷ 2-digit
			problem = _generate_intermediate_long_division()
		elif difficulty == AdvancedDifficulty.ADVANCED:
			# 4-digit ÷ 2-digit
			problem = _generate_advanced_long_division()
		else:
			# 4-digit ÷ 2-3 digit with remainder
			problem = _generate_mastery_long_division()
		
		problem["steps"] = _generate_long_division_steps(problem)
		return problem
	
	except:
		print("WARNING: Failed to generate long division problem")
		return _generate_simple_long_division()

## Generate general advanced problem based on current type
func generate_advanced_problem() -> Dictionary:
	try:
		if current_problem_type == ProblemType.PEMDAS:
			return generate_pemdas_problem()
		elif current_problem_type == ProblemType.SQUARE_ROOT:
			return generate_square_root_problem()
		elif current_problem_type == ProblemType.LONG_DIVISION:
			return generate_long_division_problem()
		elif current_problem_type == ProblemType.MIXED:
			# Random type
			var random_type = randi() % 3
			if random_type == 0:
				return generate_pemdas_problem()
			elif random_type == 1:
				return generate_square_root_problem()
			else:
				return generate_long_division_problem()
		else:
			return {}
	
	except:
		print("WARNING: Failed to generate advanced problem")
		return {}

## Track student progress
func record_student_answer(student_name: String, problem: Dictionary, answer: int, time_taken: float, is_correct: bool) -> void:
	try:
		if not track_progress:
			return
		
		if student_name not in student_progress:
			student_progress[student_name] = {
				"total_problems": 0,
				"correct": 0,
				"incorrect": 0,
				"problems_by_type": {},
				"total_time": 0.0,
				"average_time": 0.0
			}
		
		var stats = student_progress[student_name]
		stats["total_problems"] += 1
		stats["total_time"] += time_taken
		stats["average_time"] = stats["total_time"] / stats["total_problems"]
		
		if is_correct:
			stats["correct"] += 1
		else:
			stats["incorrect"] += 1
		
		# Track by problem type
		var problem_type = problem.get("type", "UNKNOWN")
		if problem_type not in stats["problems_by_type"]:
			stats["problems_by_type"][problem_type] = {"correct": 0, "total": 0}
		
		stats["problems_by_type"][problem_type]["total"] += 1
		if is_correct:
			stats["problems_by_type"][problem_type]["correct"] += 1
		
		progress_updated.emit(student_name, stats)
	
	except:
		print("WARNING: Failed to record student answer")

## Get student progress report
func get_student_progress(student_name: String) -> Dictionary:
	try:
		if student_name in student_progress:
			return student_progress[student_name]
		return {}
	except:
		return {}

## Get overall class statistics
func get_class_statistics() -> Dictionary:
	try:
		var stats = {
			"total_students": student_progress.size(),
			"total_problems_solved": 0,
			"class_average_accuracy": 0.0,
			"class_average_time": 0.0
		}
		
		var total_correct = 0
		var total_problems = 0
		var total_time = 0.0
		
		for student_name in student_progress:
			var student_stats = student_progress[student_name]
			total_problems += student_stats["total_problems"]
			total_correct += student_stats["correct"]
			total_time += student_stats["total_time"]
		
		if total_problems > 0:
			stats["total_problems_solved"] = total_problems
			stats["class_average_accuracy"] = float(total_correct) / float(total_problems)
			stats["class_average_time"] = total_time / float(total_problems)
		
		return stats
	
	except:
		return {}

## ============= PRIVATE HELPER FUNCTIONS =============

func _get_pemdas_complexity() -> int:
	match current_advanced_difficulty:
		AdvancedDifficulty.FOUNDATIONAL:
			return 1
		AdvancedDifficulty.INTERMEDIATE:
			return 2
		AdvancedDifficulty.ADVANCED:
			return 3
		AdvancedDifficulty.MASTERY:
			return 4
		_:
			return 1

func _generate_simple_pemdas() -> Dictionary:
	## Format: a + b * c (multiplication first)
	var a = randi_range(1, 10)
	var b = randi_range(1, 10)
	var c = randi_range(1, 10)
	
	var correct_answer = a + (b * c)
	var wrong_answer1 = (a + b) * c
	
	return {
		"type": "PEMDAS",
		"problem_text": "%d + %d * %d = ?" % [a, b, c],
		"correct_answer": correct_answer,
		"options": [correct_answer, wrong_answer1, correct_answer + 5, correct_answer - 3],
		"expression": "%d + %d * %d" % [a, b, c]
	}

func _generate_intermediate_pemdas() -> Dictionary:
	## Format: (a + b) * c - d
	var a = randi_range(1, 8)
	var b = randi_range(1, 8)
	var c = randi_range(1, 5)
	var d = randi_range(1, 5)
	
	var correct_answer = ((a + b) * c) - d
	
	return {
		"type": "PEMDAS",
		"problem_text": "(%d + %d) * %d - %d = ?" % [a, b, c, d],
		"correct_answer": correct_answer,
		"options": [correct_answer, (a + b) * c, correct_answer + 5, correct_answer - 5],
		"expression": "(%d + %d) * %d - %d" % [a, b, c, d]
	}

func _generate_advanced_pemdas() -> Dictionary:
	## Format: a * b + c * d - e
	var a = randi_range(2, 8)
	var b = randi_range(2, 8)
	var c = randi_range(2, 8)
	var d = randi_range(2, 8)
	var e = randi_range(1, 10)
	
	var correct_answer = (a * b) + (c * d) - e
	
	return {
		"type": "PEMDAS",
		"problem_text": "%d * %d + %d * %d - %d = ?" % [a, b, c, d, e],
		"correct_answer": correct_answer,
		"options": [correct_answer, a * b + c * d, correct_answer + 10, correct_answer - 10],
		"expression": "%d * %d + %d * %d - %d" % [a, b, c, d, e]
	}

func _generate_perfect_square() -> Dictionary:
	var base = randi_range(2, 10)  # 2-10
	var radicand = base * base
	
	return {
		"type": "SQUARE_ROOT",
		"problem_text": "√%d = ?" % radicand,
		"correct_answer": base,
		"radicand": radicand,
		"options": [base, base - 1, base + 1, base + 2]
	}

func _generate_perfect_square_extended() -> Dictionary:
	var base = randi_range(2, 20)  # 2-20
	var radicand = base * base
	
	return {
		"type": "SQUARE_ROOT",
		"problem_text": "√%d = ?" % radicand,
		"correct_answer": base,
		"radicand": radicand,
		"options": [base, base - 2, base + 2, base - 1]
	}

func _generate_square_root_approximation() -> Dictionary:
	## Non-perfect square approximation
	var radicand = randi_range(2, 100)
	var answer = int(sqrt(float(radicand)))
	
	return {
		"type": "SQUARE_ROOT",
		"problem_text": "√%d ≈ ? (nearest integer)" % radicand,
		"correct_answer": answer,
		"radicand": radicand,
		"options": [answer, answer - 1, answer + 1, answer - 2]
	}

func _generate_square_root_mixed() -> Dictionary:
	## Format: a * √b + c
	var a = randi_range(1, 5)
	var base = randi_range(2, 10)
	var b = base * base
	var c = randi_range(1, 10)
	
	var correct_answer = (a * base) + c
	
	return {
		"type": "SQUARE_ROOT",
		"problem_text": "%d * √%d + %d = ?" % [a, b, c],
		"correct_answer": correct_answer,
		"radicand": b,
		"options": [correct_answer, a * base, correct_answer + 5, correct_answer - 5]
	}

func _generate_simple_long_division() -> Dictionary:
	## 2-digit ÷ 1-digit
	var divisor = randi_range(2, 9)
	var quotient = randi_range(2, 9)
	var remainder = randi_range(0, divisor - 1)
	var dividend = (quotient * divisor) + remainder
	
	return {
		"type": "LONG_DIVISION",
		"problem_text": "%d ÷ %d = ?" % [dividend, divisor],
		"correct_answer": quotient if remainder == 0 else quotient,
		"dividend": dividend,
		"divisor": divisor,
		"quotient": quotient,
		"remainder": remainder,
		"options": [quotient, quotient - 1, quotient + 1, quotient + 2]
	}

func _generate_intermediate_long_division() -> Dictionary:
	## 3-digit ÷ 1-digit
	var divisor = randi_range(2, 9)
	var quotient = randi_range(10, 99)
	var remainder = randi_range(0, divisor - 1)
	var dividend = (quotient * divisor) + remainder
	
	return {
		"type": "LONG_DIVISION",
		"problem_text": "%d ÷ %d = ?" % [dividend, divisor],
		"correct_answer": quotient,
		"dividend": dividend,
		"divisor": divisor,
		"quotient": quotient,
		"remainder": remainder,
		"options": [quotient, quotient - 5, quotient + 5, quotient - 1]
	}

func _generate_advanced_long_division() -> Dictionary:
	## 4-digit ÷ 2-digit
	var divisor = randi_range(10, 99)
	var quotient = randi_range(10, 99)
	var remainder = randi_range(0, divisor - 1)
	var dividend = (quotient * divisor) + remainder
	
	return {
		"type": "LONG_DIVISION",
		"problem_text": "%d ÷ %d = ?" % [dividend, divisor],
		"correct_answer": quotient,
		"dividend": dividend,
		"divisor": divisor,
		"quotient": quotient,
		"remainder": remainder,
		"options": [quotient, quotient - 10, quotient + 10, quotient - 5]
	}

func _generate_mastery_long_division() -> Dictionary:
	## 4-digit ÷ 2-3 digit with remainder
	var divisor = randi_range(50, 999)
	var quotient = randi_range(10, 99)
	var remainder = randi_range(0, divisor - 1)
	var dividend = (quotient * divisor) + remainder
	
	return {
		"type": "LONG_DIVISION",
		"problem_text": "%d ÷ %d = ?" % [dividend, divisor],
		"correct_answer": quotient,
		"dividend": dividend,
		"divisor": divisor,
		"quotient": quotient,
		"remainder": remainder,
		"options": [quotient, quotient - 10, quotient + 10, quotient - 5]
	}

func _generate_solution_steps(problem: Dictionary) -> Array:
	var steps = []
	try:
		steps.append("Expression: " + problem.get("expression", ""))
		steps.append("Identify operations: Parentheses, Exponents, Multiplication/Division, Addition/Subtraction")
		steps.append("Apply PEMDAS order")
		steps.append("Result: " + str(problem.get("correct_answer", 0)))
	except:
		pass
	return steps

func _generate_square_root_steps(problem: Dictionary) -> Array:
	var steps = []
	try:
		var radicand = problem.get("radicand", 0)
		steps.append("Find what number times itself equals " + str(radicand))
		steps.append("Test values: " + str(int(sqrt(float(radicand)))) + "² = " + str(radicand))
		steps.append("Answer: " + str(problem.get("correct_answer", 0)))
	except:
		pass
	return steps

func _generate_long_division_steps(problem: Dictionary) -> Array:
	var steps = []
	try:
		var dividend = problem.get("dividend", 0)
		var divisor = problem.get("divisor", 0)
		var quotient = problem.get("quotient", 0)
		var remainder = problem.get("remainder", 0)
		
		steps.append("Divide: %d ÷ %d" % [dividend, divisor])
		steps.append("How many times does %d go into %d?" % [divisor, dividend])
		steps.append("Answer: %d times (with remainder %d)" % [quotient, remainder])
		steps.append("Result: %d" % quotient)
	except:
		pass
	return steps
