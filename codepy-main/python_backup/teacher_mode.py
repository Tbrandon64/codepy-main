#!/usr/bin/env python3
"""
MathBlat Teacher Mode - Python Backup
Fallback implementation for advanced mathematics problems.

Usage:
    from teacher_mode import TeacherMode
    teacher = TeacherMode()
    problem = teacher.generate_pemdas_problem()
"""

import random
import math
from enum import Enum
from typing import Dict, List, Tuple, Optional


class ProblemType(Enum):
    """Advanced problem types"""
    PEMDAS = "PEMDAS"
    SQUARE_ROOT = "SQUARE_ROOT"
    LONG_DIVISION = "LONG_DIVISION"


class Difficulty(Enum):
    """Difficulty levels for advanced problems"""
    FOUNDATIONAL = "FOUNDATIONAL"
    INTERMEDIATE = "INTERMEDIATE"
    ADVANCED = "ADVANCED"
    MASTERY = "MASTERY"


class TeacherMode:
    """Advanced mathematics problem generator for teacher mode.
    
    Generates progressively complex math problems in three categories:
    - PEMDAS (Order of Operations)
    - SQUARE_ROOT (Radical expressions)
    - LONG_DIVISION (Multi-step division)
    
    Supports four difficulty levels: FOUNDATIONAL, INTERMEDIATE, ADVANCED, MASTERY
    """
    
    def __init__(self):
        """Initialize teacher mode system with foundational difficulty.
        
        Sets up tracking for difficulty level and problem generation count.
        """
        # Current difficulty setting for problem generation
        self.current_difficulty = Difficulty.FOUNDATIONAL
        # Counter for problems generated during session
        self.problems_generated = 0
    
    def set_difficulty(self, difficulty: str) -> bool:
        """Set problem difficulty level.
        
        Args:
            difficulty: Difficulty level name ("FOUNDATIONAL", "INTERMEDIATE", 
                       "ADVANCED", or "MASTERY")
        
        Returns:
            True if difficulty set successfully, False if invalid
        """
        try:
            # Convert string to Difficulty enum
            self.current_difficulty = Difficulty[difficulty]
            return True
        except KeyError:
            print(f"WARNING: Unknown difficulty '{difficulty}'")
            return False
    
    # PEMDAS Problems
    def generate_pemdas_problem(self) -> Dict:
        """
        Generate PEMDAS (Order of Operations) problem.
        
        Returns:
            Problem dictionary with expression and correct answer
        """
        try:
            if self.current_difficulty == Difficulty.FOUNDATIONAL:
                return self._generate_simple_pemdas()
            elif self.current_difficulty == Difficulty.INTERMEDIATE:
                return self._generate_intermediate_pemdas()
            elif self.current_difficulty == Difficulty.ADVANCED:
                return self._generate_advanced_pemdas()
            else:
                return self._generate_mastery_pemdas()
        
        except Exception as e:
            print(f"WARNING: Failed to generate PEMDAS problem: {e}")
            return self._generate_simple_pemdas()
    
    def _generate_simple_pemdas(self) -> Dict:
        """a + b * c (multiplication first)"""
        a = random.randint(1, 10)
        b = random.randint(1, 10)
        c = random.randint(1, 10)
        
        correct = a + (b * c)
        wrong = (a + b) * c
        
        return {
            "type": "PEMDAS",
            "problem_text": f"{a} + {b} * {c} = ?",
            "expression": f"{a} + {b} * {c}",
            "correct_answer": correct,
            "options": [correct, wrong, correct + 5, correct - 3],
            "steps": [
                f"1. Multiply first: {b} * {c} = {b * c}",
                f"2. Then add: {a} + {b * c} = {correct}",
                f"Answer: {correct}"
            ]
        }
    
    def _generate_intermediate_pemdas(self) -> Dict:
        """(a + b) * c - d"""
        a = random.randint(1, 8)
        b = random.randint(1, 8)
        c = random.randint(1, 5)
        d = random.randint(1, 5)
        
        correct = ((a + b) * c) - d
        
        return {
            "type": "PEMDAS",
            "problem_text": f"({a} + {b}) * {c} - {d} = ?",
            "expression": f"({a} + {b}) * {c} - {d}",
            "correct_answer": correct,
            "options": [correct, (a + b) * c, correct + 5, correct - 5],
            "steps": [
                f"1. Parentheses first: {a} + {b} = {a + b}",
                f"2. Multiply: {a + b} * {c} = {(a + b) * c}",
                f"3. Subtract: {(a + b) * c} - {d} = {correct}",
                f"Answer: {correct}"
            ]
        }
    
    def _generate_advanced_pemdas(self) -> Dict:
        """a * b + c * d - e"""
        a = random.randint(2, 8)
        b = random.randint(2, 8)
        c = random.randint(2, 8)
        d = random.randint(2, 8)
        e = random.randint(1, 10)
        
        correct = (a * b) + (c * d) - e
        
        return {
            "type": "PEMDAS",
            "problem_text": f"{a} * {b} + {c} * {d} - {e} = ?",
            "expression": f"{a} * {b} + {c} * {d} - {e}",
            "correct_answer": correct,
            "options": [correct, a * b + c * d, correct + 10, correct - 10],
            "steps": [
                f"1. First multiplication: {a} * {b} = {a * b}",
                f"2. Second multiplication: {c} * {d} = {c * d}",
                f"3. Add: {a * b} + {c * d} = {(a * b) + (c * d)}",
                f"4. Subtract: {(a * b) + (c * d)} - {e} = {correct}",
                f"Answer: {correct}"
            ]
        }
    
    def _generate_mastery_pemdas(self) -> Dict:
        """Complex: a * b - c * d + e / f"""
        a = random.randint(3, 9)
        b = random.randint(3, 9)
        c = random.randint(2, 8)
        d = random.randint(2, 8)
        e = random.randint(10, 20)
        f = random.randint(2, 5)
        
        correct = (a * b) - (c * d) + (e // f)
        
        return {
            "type": "PEMDAS",
            "problem_text": f"{a} * {b} - {c} * {d} + {e} / {f} = ?",
            "expression": f"{a} * {b} - {c} * {d} + {e} / {f}",
            "correct_answer": correct,
            "options": [correct, a * b - c * d, correct + 15, correct - 15],
            "steps": [
                f"1. First: {a} * {b} = {a * b}",
                f"2. Second: {c} * {d} = {c * d}",
                f"3. Division: {e} / {f} = {e // f}",
                f"4. Calculate: {a * b} - {c * d} + {e // f} = {correct}",
                f"Answer: {correct}"
            ]
        }
    
    # Square Root Problems
    def generate_square_root_problem(self) -> Dict:
        """
        Generate square root problem.
        
        Returns:
            Problem dictionary with radical and answer
        """
        try:
            if self.current_difficulty == Difficulty.FOUNDATIONAL:
                return self._generate_perfect_square()
            elif self.current_difficulty == Difficulty.INTERMEDIATE:
                return self._generate_perfect_square_extended()
            elif self.current_difficulty == Difficulty.ADVANCED:
                return self._generate_square_root_approximation()
            else:
                return self._generate_square_root_mixed()
        
        except Exception as e:
            print(f"WARNING: Failed to generate square root problem: {e}")
            return self._generate_perfect_square()
    
    def _generate_perfect_square(self) -> Dict:
        """Perfect squares 2²-10²"""
        base = random.randint(2, 10)
        radicand = base * base
        
        return {
            "type": "SQUARE_ROOT",
            "problem_text": f"√{radicand} = ?",
            "radicand": radicand,
            "correct_answer": base,
            "options": [base, base - 1, base + 1, base + 2],
            "steps": [
                f"What number times itself equals {radicand}?",
                f"{base} × {base} = {radicand}",
                f"Answer: √{radicand} = {base}"
            ]
        }
    
    def _generate_perfect_square_extended(self) -> Dict:
        """Perfect squares 2²-20²"""
        base = random.randint(2, 20)
        radicand = base * base
        
        return {
            "type": "SQUARE_ROOT",
            "problem_text": f"√{radicand} = ?",
            "radicand": radicand,
            "correct_answer": base,
            "options": [base, base - 2, base + 2, base - 1],
            "steps": [
                f"Find the square root of {radicand}",
                f"Test: {base} × {base} = {radicand} ✓",
                f"Answer: √{radicand} = {base}"
            ]
        }
    
    def _generate_square_root_approximation(self) -> Dict:
        """Non-perfect square approximation"""
        radicand = random.randint(2, 100)
        answer = int(math.sqrt(float(radicand)))
        
        return {
            "type": "SQUARE_ROOT",
            "problem_text": f"√{radicand} ≈ ? (nearest integer)",
            "radicand": radicand,
            "correct_answer": answer,
            "options": [answer, answer - 1, answer + 1, answer - 2],
            "steps": [
                f"Find √{radicand}",
                f"{answer}² = {answer * answer}",
                f"{answer + 1}² = {(answer + 1) * (answer + 1)}",
                f"{radicand} is between these, so √{radicand} ≈ {answer}"
            ]
        }
    
    def _generate_square_root_mixed(self) -> Dict:
        """a * √b + c"""
        a = random.randint(1, 5)
        base = random.randint(2, 10)
        b = base * base
        c = random.randint(1, 10)
        
        correct = (a * base) + c
        
        return {
            "type": "SQUARE_ROOT",
            "problem_text": f"{a} * √{b} + {c} = ?",
            "radicand": b,
            "correct_answer": correct,
            "options": [correct, a * base, correct + 5, correct - 5],
            "steps": [
                f"1. Find √{b} = {base}",
                f"2. Multiply: {a} × {base} = {a * base}",
                f"3. Add: {a * base} + {c} = {correct}",
                f"Answer: {correct}"
            ]
        }
    
    # Long Division Problems
    def generate_long_division_problem(self) -> Dict:
        """
        Generate long division problem.
        
        Returns:
            Problem dictionary with division and quotient
        """
        try:
            if self.current_difficulty == Difficulty.FOUNDATIONAL:
                return self._generate_simple_long_division()
            elif self.current_difficulty == Difficulty.INTERMEDIATE:
                return self._generate_intermediate_long_division()
            elif self.current_difficulty == Difficulty.ADVANCED:
                return self._generate_advanced_long_division()
            else:
                return self._generate_mastery_long_division()
        
        except Exception as e:
            print(f"WARNING: Failed to generate long division problem: {e}")
            return self._generate_simple_long_division()
    
    def _generate_simple_long_division(self) -> Dict:
        """2-digit ÷ 1-digit"""
        divisor = random.randint(2, 9)
        quotient = random.randint(2, 9)
        remainder = random.randint(0, divisor - 1)
        dividend = (quotient * divisor) + remainder
        
        return {
            "type": "LONG_DIVISION",
            "problem_text": f"{dividend} ÷ {divisor} = ?",
            "dividend": dividend,
            "divisor": divisor,
            "correct_answer": quotient,
            "remainder": remainder,
            "options": [quotient, quotient - 1, quotient + 1, quotient + 2],
            "steps": [
                f"Divide {dividend} by {divisor}",
                f"{divisor} goes into {dividend} {quotient} times",
                f"{quotient} × {divisor} = {quotient * divisor}",
                f"Remainder: {dividend} - {quotient * divisor} = {remainder}",
                f"Answer: {quotient}" + (f" R{remainder}" if remainder > 0 else "")
            ]
        }
    
    def _generate_intermediate_long_division(self) -> Dict:
        """3-digit ÷ 1-digit"""
        divisor = random.randint(2, 9)
        quotient = random.randint(10, 99)
        remainder = random.randint(0, divisor - 1)
        dividend = (quotient * divisor) + remainder
        
        return {
            "type": "LONG_DIVISION",
            "problem_text": f"{dividend} ÷ {divisor} = ?",
            "dividend": dividend,
            "divisor": divisor,
            "correct_answer": quotient,
            "remainder": remainder,
            "options": [quotient, quotient - 5, quotient + 5, quotient - 1],
            "steps": [
                f"Setup: {dividend} ÷ {divisor}",
                f"First digit: {dividend // (divisor * 10)} × {divisor}",
                f"Continue dividing: Answer is {quotient}",
                f"Check: {quotient} × {divisor} = {quotient * divisor}",
                f"Answer: {quotient}" + (f" R{remainder}" if remainder > 0 else "")
            ]
        }
    
    def _generate_advanced_long_division(self) -> Dict:
        """4-digit ÷ 2-digit"""
        divisor = random.randint(10, 99)
        quotient = random.randint(10, 99)
        remainder = random.randint(0, divisor - 1)
        dividend = (quotient * divisor) + remainder
        
        return {
            "type": "LONG_DIVISION",
            "problem_text": f"{dividend} ÷ {divisor} = ?",
            "dividend": dividend,
            "divisor": divisor,
            "correct_answer": quotient,
            "remainder": remainder,
            "options": [quotient, quotient - 10, quotient + 10, quotient - 5],
            "steps": [
                f"Setup: {dividend} ÷ {divisor}",
                f"Estimate: How many {divisor}s fit in {dividend}?",
                f"Try {quotient}: {quotient} × {divisor} = {quotient * divisor}",
                f"Remainder: {dividend} - {quotient * divisor} = {remainder}",
                f"Answer: {quotient}" + (f" R{remainder}" if remainder > 0 else "")
            ]
        }
    
    def _generate_mastery_long_division(self) -> Dict:
        """4+ digit ÷ 2-3 digit with remainder"""
        divisor = random.randint(50, 999)
        quotient = random.randint(10, 99)
        remainder = random.randint(0, divisor - 1)
        dividend = (quotient * divisor) + remainder
        
        return {
            "type": "LONG_DIVISION",
            "problem_text": f"{dividend} ÷ {divisor} = ?",
            "dividend": dividend,
            "divisor": divisor,
            "correct_answer": quotient,
            "remainder": remainder,
            "options": [quotient, quotient - 10, quotient + 10, quotient - 5],
            "steps": [
                f"Setup: {dividend} ÷ {divisor}",
                f"Divide step by step",
                f"Quotient: {quotient}",
                f"Check: {quotient} × {divisor} = {quotient * divisor}",
                f"Remainder: {remainder}",
                f"Answer: {quotient}" + (f" R{remainder}" if remainder > 0 else "")
            ]
        }
    
    # Batch and Statistics
    def generate_problem_set(self, problem_type: str, count: int = 5) -> List[Dict]:
        """Generate multiple problems of specified type"""
        try:
            problems = []
            for _ in range(count):
                if problem_type == "PEMDAS":
                    problems.append(self.generate_pemdas_problem())
                elif problem_type == "SQUARE_ROOT":
                    problems.append(self.generate_square_root_problem())
                elif problem_type == "LONG_DIVISION":
                    problems.append(self.generate_long_division_problem())
            
            self.problems_generated += len(problems)
            return problems
        
        except Exception as e:
            print(f"WARNING: Failed to generate problem set: {e}")
            return []
    
    def get_statistics(self) -> Dict:
        """Get statistics"""
        return {
            "problems_generated": self.problems_generated,
            "current_difficulty": self.current_difficulty.value,
            "version": "1.0"
        }


if __name__ == "__main__":
    print("=== MathBlat Teacher Mode (Python Backup) ===\n")
    
    teacher = TeacherMode()
    
    # Test PEMDAS
    print("PEMDAS Problems:")
    for diff in ["FOUNDATIONAL", "INTERMEDIATE", "ADVANCED"]:
        teacher.set_difficulty(diff)
        problem = teacher.generate_pemdas_problem()
        print(f"  {diff}: {problem['problem_text']} = {problem['correct_answer']}")
    
    print("\nSquare Root Problems:")
    for diff in ["FOUNDATIONAL", "INTERMEDIATE", "ADVANCED"]:
        teacher.set_difficulty(diff)
        problem = teacher.generate_square_root_problem()
        print(f"  {diff}: {problem['problem_text']} = {problem['correct_answer']}")
    
    print("\nLong Division Problems:")
    for diff in ["FOUNDATIONAL", "INTERMEDIATE", "ADVANCED"]:
        teacher.set_difficulty(diff)
        problem = teacher.generate_long_division_problem()
        print(f"  {diff}: {problem['problem_text']} = {problem['correct_answer']}")
