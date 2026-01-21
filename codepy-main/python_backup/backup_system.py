#!/usr/bin/env python3
"""
MathBlat Backup System - Main Module
Unified interface for all Python backup systems.

This module provides a comprehensive backup interface that mirrors the Godot
SystemManager, allowing the game to fall back to Python implementations if
Godot systems fail completely.

Features:
- Lazy loading of optional systems
- Error caching for debugging
- Unified interface for all backups
- Optional teacher mode support

Usage:
    from backup_system import BackupSystem
    backup = BackupSystem()
    
    # Check backup availability
    if backup.is_available():
        problem = backup.generate_problem("MEDIUM")
        backup.save_score("Player", 100, "MEDIUM")
"""

import sys
from pathlib import Path
from typing import Dict, Optional

# Import backup modules
from problem_generator import ProblemGenerator, Difficulty
from score_manager import ScoreManager
from config_manager import ConfigManager

# Teacher mode is optional - import but don't require
try:
    from teacher_mode import TeacherMode, ProblemType, Difficulty as TeacherDifficulty
    TEACHER_MODE_AVAILABLE = True
except ImportError:
    TEACHER_MODE_AVAILABLE = False
    TeacherMode = None


class BackupSystem:
    """Unified backup system interface for MathBlat.
    
    Provides fallback implementations for core game systems (problem generation,
    score management, configuration) if Godot systems fail completely.
    Implements lazy-loading for optional features like teacher mode.
    """
    
    def __init__(self):
        """Initialize all backup systems with error handling.
        
        Sets up core systems: problem generator, score manager, and config manager.
        Teacher mode is lazy-loaded on first use for performance.
        """
        # Core backup systems
        self.problem_gen = None
        self.score_manager = None
        self.config_manager = None
        self.teacher_mode = None
        
        # Status tracking
        self.initialized = False
        self.errors = []
        self._teacher_mode_initialized = False
        
        self._initialize_systems()
    
    def _initialize_systems(self) -> None:
        """Initialize all backup systems with error handling"""
        try:
            self.problem_gen = ProblemGenerator(difficulty="MEDIUM")
            self.score_manager = ScoreManager()
            self.config_manager = ConfigManager()
            
            self.initialized = True
            print("✅ Backup systems initialized successfully")
        
        except Exception as e:
            self.initialized = False
            self.errors.append(f"Backup system initialization failed: {e}")
            print(f"❌ {self.errors[-1]}")
    
    def _initialize_teacher_mode(self) -> None:
        """Lazy-load teacher mode on first use (optional)"""
        if self._teacher_mode_initialized or not TEACHER_MODE_AVAILABLE:
            return
        
        self._teacher_mode_initialized = True
        
        try:
            self.teacher_mode = TeacherMode()
            print("✅ Teacher mode initialized successfully")
        except Exception as te:
            self.teacher_mode = None
            self._log_error(f"Teacher mode initialization failed: {te}")
    
    def is_available(self) -> bool:
        """Check if backup systems are available"""
        return self.initialized

    
    # Problem Generation Backup
    def generate_problem(self, difficulty: str = "MEDIUM") -> Optional[Dict]:
        """
        Generate a math problem using Python backup.
        
        Args:
            difficulty: EASY, MEDIUM, or HARD
        
        Returns:
            Problem dictionary or None if failed
        """
        try:
            if not self.problem_gen:
                self.errors.append("Problem generator not initialized")
                return None
            
            self.problem_gen.set_difficulty(difficulty)
            return self.problem_gen.generate_problem()
        
        except Exception as e:
            self.errors.append(f"Problem generation failed: {e}")
            return None
    
    def generate_problems(self, count: int, difficulty: str = "MEDIUM") -> list:
        """Generate multiple problems"""
        try:
            if not self.problem_gen:
                return []
            
            self.problem_gen.set_difficulty(difficulty)
            return self.problem_gen.generate_batch(count)
        
        except Exception as e:
            self.errors.append(f"Batch problem generation failed: {e}")
            return []
    
    # Score Management Backup
    def save_score(self, player_name: str, score: int, difficulty: str) -> bool:
        """
        Save a high score using Python backup.
        
        Args:
            player_name: Player name
            score: Score achieved
            difficulty: Difficulty level
        
        Returns:
            True if saved successfully
        """
        try:
            if not self.score_manager:
                self.errors.append("Score manager not initialized")
                return False
            
            return self.score_manager.save_score(player_name, score, difficulty)
        
        except Exception as e:
            self.errors.append(f"Score save failed: {e}")
            return False
    
    def load_scores(self) -> list:
        """Get all high scores"""
        try:
            if not self.score_manager:
                return []
            
            return self.score_manager.get_high_scores()
        
        except Exception as e:
            self.errors.append(f"Score load failed: {e}")
            return []
    
    def get_top_scores(self, count: int = 5) -> list:
        """Get top N scores"""
        try:
            if not self.score_manager:
                return []
            
            return self.score_manager.get_top_scores(count)
        
        except Exception as e:
            self.errors.append(f"Top scores retrieval failed: {e}")
            return []
    
    def is_high_score(self, score: int) -> bool:
        """Check if score qualifies for high scores"""
        try:
            if not self.score_manager:
                return False
            
            return self.score_manager.is_high_score(score)
        
        except Exception as e:
            self.errors.append(f"High score check failed: {e}")
            return False
    
    # Configuration Management Backup
    def load_setting(self, category: str, key: str, default=None):
        """Load a configuration setting"""
        try:
            if not self.config_manager:
                return default
            
            return self.config_manager.load_setting(category, key, default)
        
        except Exception as e:
            self.errors.append(f"Setting load failed {category}.{key}: {e}")
            return default
    
    def save_setting(self, category: str, key: str, value) -> bool:
        """Save a configuration setting"""
        try:
            if not self.config_manager:
                return False
            
            return self.config_manager.save_setting(category, key, value)
        
        except Exception as e:
            self.errors.append(f"Setting save failed {category}.{key}: {e}")
            return False
    
    def get_config(self, category: str) -> Dict:
        """Get all settings in a category"""
        try:
            if not self.config_manager:
                return {}
            
            return self.config_manager.get_category(category)
        
        except Exception as e:
            self.errors.append(f"Config retrieval failed: {e}")
            return {}
    
    # Status and Reporting
    def get_status(self) -> Dict:
        """Get backup system status"""
        return {
            "available": self.initialized,
            "problem_generator": self.problem_gen is not None,
            "score_manager": self.score_manager is not None,
            "config_manager": self.config_manager is not None,
            "teacher_mode": self.teacher_mode is not None,
            "error_count": len(self.errors),
            "recent_errors": self.errors[-5:] if self.errors else []
        }
    
    def get_errors(self) -> list:
        """Get all recorded errors"""
        return self.errors.copy()
    
    def clear_errors(self) -> None:
        """Clear error history"""
        self.errors = []
    
    def report_status(self) -> str:
        """Get formatted status report"""
        status = self.get_status()
        
        report = [
            "=== Python Backup System Status ===",
            f"Initialized: {'✅ Yes' if status['available'] else '❌ No'}",
            f"Problem Generator: {'✅ Ready' if status['problem_generator'] else '❌ Failed'}",
            f"Score Manager: {'✅ Ready' if status['score_manager'] else '❌ Failed'}",
            f"Config Manager: {'✅ Ready' if status['config_manager'] else '❌ Failed'}",
            f"Teacher Mode: {'✅ Ready' if status['teacher_mode'] else '❌ Failed'}",
            f"Errors Recorded: {status['error_count']}",
        ]
        
        if status['recent_errors']:
            report.append("\nRecent Errors:")
            for error in status['recent_errors']:
                report.append(f"  • {error}")
        
        return "\n".join(report)
    
    # Teacher Mode Interface
    def _log_error(self, message: str) -> None:
        """Log error for teacher mode methods"""
        self.errors.append(message)
    
    def generate_pemdas_problem(self, difficulty: str = "FOUNDATIONAL") -> Dict:
        """Generate a PEMDAS (Order of Operations) problem.
        
        Optional teacher mode feature - returns empty dict if not available.
        Lazy-loads teacher mode on first call.
        
        Args:
            difficulty: "FOUNDATIONAL", "INTERMEDIATE", "ADVANCED", or "MASTERY"
        
        Returns:
            Dictionary with problem_text, correct_answer, options, and steps
            or empty dict if teacher mode not available
        """
        # Lazy-load teacher mode on first use
        if not self._teacher_mode_initialized:
            self._initialize_teacher_mode()
        
        if not self.teacher_mode:
            return {}
        
        try:
            self.teacher_mode.set_difficulty(difficulty)
            return self.teacher_mode.generate_pemdas_problem()
        except Exception as e:
            self._log_error(f"PEMDAS generation failed: {e}")
            return {}
    
    def generate_square_root_problem(self, difficulty: str = "FOUNDATIONAL") -> Dict:
        """Generate a square root problem.
        
        Optional teacher mode feature - returns empty dict if not available.
        Lazy-loads teacher mode on first call.
        
        Args:
            difficulty: "FOUNDATIONAL" (perfect squares), 
                       "INTERMEDIATE" (perfect + approximation),
                       "ADVANCED" (mixed operations),
                       "MASTERY" (complex combinations)
        
        Returns:
            Dictionary with problem_text, correct_answer, options, and steps
            or empty dict if teacher mode not available
        """
        # Lazy-load teacher mode on first use
        if not self._teacher_mode_initialized:
            self._initialize_teacher_mode()
        
        if not self.teacher_mode:
            return {}
        
        try:
            self.teacher_mode.set_difficulty(difficulty)
            return self.teacher_mode.generate_square_root_problem()
        except Exception as e:
            self._log_error(f"Square root generation failed: {e}")
            return {}
    
    def generate_long_division_problem(self, difficulty: str = "FOUNDATIONAL") -> Dict:
        """Generate a long division problem with step-by-step solution.
        
        Optional teacher mode feature - returns empty dict if not available.
        Lazy-loads teacher mode on first call.
        
        Args:
            difficulty: "FOUNDATIONAL" (single-digit),
                       "INTERMEDIATE" (2-digit divisor),
                       "ADVANCED" (larger numbers),
                       "MASTERY" (complex with remainders)
        
        Returns:
            Dictionary with problem_text, correct_answer, options, and steps
            or empty dict if teacher mode not available
        """
        # Lazy-load teacher mode on first use
        if not self._teacher_mode_initialized:
            self._initialize_teacher_mode()
        
        if not self.teacher_mode:
            return {}
        
        try:
            self.teacher_mode.set_difficulty(difficulty)
            return self.teacher_mode.generate_long_division_problem()
        except Exception as e:
            self._log_error(f"Long division generation failed: {e}")
            return {}
    
    def generate_teacher_problem(self, problem_type: str, difficulty: str = "FOUNDATIONAL") -> Dict:
        """Generate any teacher mode problem type.
        
        Optional teacher mode feature - returns empty dict if not available.
        Lazy-loads teacher mode on first call.
        
        Args:
            problem_type: "PEMDAS", "SQUARE_ROOT", or "LONG_DIVISION"
            difficulty: "FOUNDATIONAL", "INTERMEDIATE", "ADVANCED", or "MASTERY"
        
        Returns:
            Dictionary with problem_text, correct_answer, options, and steps
            or empty dict if teacher mode not available
        """
        # Lazy-load teacher mode on first use
        if not self._teacher_mode_initialized:
            self._initialize_teacher_mode()
        
        if not self.teacher_mode:
            return {}
        
        try:
            self.teacher_mode.set_difficulty(difficulty)
            
            if problem_type == "PEMDAS":
                return self.teacher_mode.generate_pemdas_problem()
            elif problem_type == "SQUARE_ROOT":
                return self.teacher_mode.generate_square_root_problem()
            elif problem_type == "LONG_DIVISION":
                return self.teacher_mode.generate_long_division_problem()
            else:
                self._log_error(f"Unknown problem type: {problem_type}")
                return {}
        except Exception as e:
            self._log_error(f"Teacher problem generation failed: {e}")
            return {}


# Global instance for easy access
_backup_instance = None


def get_backup_system() -> BackupSystem:
    """Get or create the global backup system instance"""
    global _backup_instance
    if _backup_instance is None:
        _backup_instance = BackupSystem()
    return _backup_instance


if __name__ == "__main__":
    print("=== MathBlat Python Backup System ===\n")
    
    backup = BackupSystem()
    print(backup.report_status())
    
    print("\n=== Testing Problem Generation ===")
    for difficulty in ["EASY", "MEDIUM", "HARD"]:
        problem = backup.generate_problem(difficulty)
        if problem:
            print(f"✅ {difficulty}: {problem['problem_text']}")
        else:
            print(f"❌ {difficulty}: Failed")
    
    print("\n=== Testing Teacher Mode ===")
    if backup.teacher_mode:
        for diff in ["FOUNDATIONAL", "INTERMEDIATE", "ADVANCED"]:
            backup.teacher_mode.set_difficulty(diff)
            
            pemdas = backup.teacher_mode.generate_pemdas_problem()
            sqrt = backup.teacher_mode.generate_square_root_problem()
            division = backup.teacher_mode.generate_long_division_problem()
            
            print(f"\n{diff}:")
            print(f"  PEMDAS: {pemdas['problem_text']}")
            print(f"  Square Root: {sqrt['problem_text']}")
            print(f"  Long Division: {division['problem_text']}")
    
    print("\n=== Testing Score Management ===")
    backup.save_score("Test Player", 150, "MEDIUM")
    scores = backup.load_scores()
    print(f"✅ Saved and loaded {len(scores)} scores")
    
    print("\n=== Testing Configuration ===")
    backup.save_setting("Game", "TestKey", "TestValue")
    value = backup.load_setting("Game", "TestKey")
    print(f"✅ Config test: {value}")
