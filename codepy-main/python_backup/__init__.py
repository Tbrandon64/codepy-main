"""
MathBlat Python Backup Package

Provides fallback implementations for critical game systems if Godot
implementations fail completely.

Example:
    from python_backup import BackupSystem
    backup = BackupSystem()
    problem = backup.generate_problem("MEDIUM")
"""

from .backup_system import BackupSystem, get_backup_system
from .problem_generator import ProblemGenerator, Difficulty
from .score_manager import ScoreManager
from .config_manager import ConfigManager

__version__ = "1.0"
__all__ = [
    "BackupSystem",
    "get_backup_system",
    "ProblemGenerator",
    "Difficulty",
    "ScoreManager",
    "ConfigManager",
]
