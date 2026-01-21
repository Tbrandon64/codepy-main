#!/usr/bin/env python3
"""
MathBlat Problem Generator - Python Backup
Fallback implementation for generating math problems if Godot system fails.

Usage:
    from problem_generator import ProblemGenerator
    gen = ProblemGenerator(difficulty="MEDIUM")
    problem = gen.generate_problem()
"""

import random
import json
from enum import Enum
from typing import Dict, List, Tuple


class Difficulty(Enum):
    """Difficulty levels matching Godot implementation"""
    EASY = "EASY"
    MEDIUM = "MEDIUM"
    HARD = "HARD"


class ProblemGenerator:
    """Generate math problems with consistent interface to Godot version"""
    
    # Difficulty ranges (matching Godot)
    DIFFICULTY_RANGES = {
        Difficulty.EASY: {"min": 1, "max": 10, "points": 10},
        Difficulty.MEDIUM: {"min": 1, "max": 50, "points": 20},
        Difficulty.HARD: {"min": 1, "max": 100, "points": 30},
    }
    
    # Available operations
    OPERATIONS = ["+", "-", "*", "/"]
    
    def __init__(self, difficulty: str = "MEDIUM"):
        """Initialize generator with difficulty level"""
        try:
            self.difficulty = Difficulty[difficulty]
        except KeyError:
            print(f"WARNING: Unknown difficulty '{difficulty}', using MEDIUM")
            self.difficulty = Difficulty.MEDIUM
        
        self.problems_generated = 0
    
    def generate_problem(self) -> Dict:
        """
        Generate a single math problem.
        
        Returns:
            Dictionary with: operand1, operand2, operation, correct_answer,
                           options (list of 4), problem_text
        """
        try:
            problem_data = self.DIFFICULTY_RANGES.get(
                self.difficulty,
                self.DIFFICULTY_RANGES[Difficulty.MEDIUM]
            )
            
            min_num = problem_data["min"]
            max_num = problem_data["max"]
            
            # Generate random operands
            operand1 = random.randint(min_num, max_num)
            operand2 = random.randint(max(1, min_num), max_num)
            
            # Choose random operation
            operation = random.choice(self.OPERATIONS)
            
            # Calculate correct answer
            correct_answer = self._calculate_answer(operand1, operand2, operation)
            if correct_answer is None:
                # If calculation failed, use fallback
                return self._generate_fallback_problem()
            
            # Generate problem text
            problem_text = f"{operand1} {operation} {operand2} = ?"
            
            # Generate 4 options
            options = self._generate_options(correct_answer)
            
            self.problems_generated += 1
            
            return {
                "operand1": operand1,
                "operand2": operand2,
                "operation": operation,
                "correct_answer": correct_answer,
                "problem_text": problem_text,
                "options": options,
                "points": problem_data["points"]
            }
        
        except Exception as e:
            print(f"WARNING: Failed to generate problem: {e}")
            return self._generate_fallback_problem()
    
    def _calculate_answer(self, op1: int, op2: int, operation: str) -> int:
        """Calculate correct answer for given operands and operation"""
        try:
            if operation == "+":
                return op1 + op2
            elif operation == "-":
                return op1 - op2
            elif operation == "*":
                return op1 * op2
            elif operation == "/":
                # Ensure integer division
                if op2 == 0:
                    return None
                if op1 % op2 != 0:
                    # Adjust to make divisible
                    return op1 // op2
                return op1 // op2
            else:
                return None
        except Exception:
            return None
    
    def _generate_options(self, correct_answer: int, max_attempts: int = 50) -> List[int]:
        """Generate 4 unique answer options"""
        try:
            options = [correct_answer]
            attempts = 0
            
            while len(options) < 4 and attempts < max_attempts:
                offset = random.randint(1, max(5, abs(correct_answer)))
                
                if random.random() < 0.5:
                    wrong_answer = correct_answer + offset
                else:
                    wrong_answer = correct_answer - offset
                
                if wrong_answer > 0 and wrong_answer not in options:
                    options.append(wrong_answer)
                
                attempts += 1
            
            # Fallback if we couldn't generate enough
            while len(options) < 4:
                fallback = correct_answer + random.randint(-correct_answer + 1, correct_answer * 2)
                if fallback > 0 and fallback not in options:
                    options.append(fallback)
            
            random.shuffle(options)
            return options[:4]
        
        except Exception as e:
            print(f"WARNING: Failed to generate options: {e}")
            # Return simple fallback options
            return [correct_answer, correct_answer + 1, correct_answer + 2, correct_answer - 1]
    
    def _generate_fallback_problem(self) -> Dict:
        """Generate a guaranteed working fallback problem"""
        return {
            "operand1": 5,
            "operand2": 3,
            "operation": "+",
            "correct_answer": 8,
            "problem_text": "5 + 3 = ?",
            "options": [8, 7, 9, 6],
            "points": 10
        }
    
    def set_difficulty(self, difficulty: str) -> bool:
        """Change difficulty level"""
        try:
            self.difficulty = Difficulty[difficulty]
            return True
        except KeyError:
            print(f"WARNING: Unknown difficulty '{difficulty}'")
            return False
    
    def generate_batch(self, count: int = 5) -> List[Dict]:
        """Generate multiple problems at once"""
        try:
            return [self.generate_problem() for _ in range(count)]
        except Exception as e:
            print(f"WARNING: Failed to generate batch: {e}")
            return [self._generate_fallback_problem()]
    
    def get_stats(self) -> Dict:
        """Get generator statistics"""
        return {
            "problems_generated": self.problems_generated,
            "current_difficulty": self.difficulty.value,
            "version": "1.0"
        }


if __name__ == "__main__":
    # Example usage
    print("=== MathBlat Problem Generator (Python Backup) ===\n")
    
    gen = ProblemGenerator(difficulty="MEDIUM")
    
    for i in range(3):
        problem = gen.generate_problem()
        print(f"Problem {i+1}: {problem['problem_text']}")
        print(f"  Answer: {problem['correct_answer']}")
        print(f"  Options: {problem['options']}")
        print(f"  Points: {problem['points']}\n")
    
    print(f"Stats: {gen.get_stats()}")
