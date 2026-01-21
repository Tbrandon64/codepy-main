#!/usr/bin/env python3
"""
MathBlat Score Manager - Python Backup
Fallback implementation for managing high scores if Godot system fails.

Usage:
    from score_manager import ScoreManager
    manager = ScoreManager()
    manager.save_score("Player", 100, "MEDIUM")
    scores = manager.get_high_scores()
"""

import json
import os
from pathlib import Path
from typing import Dict, List, Optional
from datetime import datetime


class ScoreManager:
    """Manage high scores with persistent JSON storage.
    
    Stores and retrieves player high scores with automatic ranking.
    Persists scores to ~/.mathblat/high_scores.json by default.
    Maintains a maximum of 10 high score entries.
    """
    
    # Default storage directory (~/.mathblat/)
    DEFAULT_SCORES_DIR = Path.home() / ".mathblat"
    # Default scores file location
    DEFAULT_SCORES_FILE = DEFAULT_SCORES_DIR / "high_scores.json"
    # Maximum number of high scores to keep
    MAX_HIGH_SCORES = 10
    
    def __init__(self, scores_file: Optional[str] = None):
        """Initialize score manager with optional custom file path.
        
        Creates ~/.mathblat directory if needed and loads existing scores.
        
        Args:
            scores_file: Custom file path for scores. If None, uses default.
        """
        try:
            # Use custom path if provided, otherwise use default location
            if scores_file:
                self.scores_file = Path(scores_file)
            else:
                self.scores_file = self.DEFAULT_SCORES_FILE
            
            # Create directory structure if it doesn't exist
            self.scores_file.parent.mkdir(parents=True, exist_ok=True)
            
            # Initialize scores list and load from file
            self.high_scores: List[Dict] = []
            self.load_scores()
        
        except Exception as e:
            print(f"WARNING: Failed to initialize ScoreManager: {e}")
            self.high_scores = []
    
    def save_score(self, player_name: str, score: int, difficulty: str) -> bool:
        """
        Save a new high score entry.
        
        Args:
            player_name: Name of the player
            score: Score achieved
            difficulty: Difficulty level (EASY, MEDIUM, HARD)
        
        Returns:
            True if saved successfully, False otherwise
        """
        try:
            new_entry = {
                "name": player_name[:50],  # Limit name length
                "score": int(score),
                "difficulty": difficulty,
                "date": datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            }
            
            self.high_scores.append(new_entry)
            
            # Sort by score descending
            self.high_scores.sort(key=lambda x: x["score"], reverse=True)
            
            # Keep only top 10
            if len(self.high_scores) > self.MAX_HIGH_SCORES:
                self.high_scores = self.high_scores[:self.MAX_HIGH_SCORES]
            
            return self._write_scores_to_file()
        
        except Exception as e:
            print(f"WARNING: Failed to save score: {e}")
            return False
    
    def load_scores(self) -> List[Dict]:
        """
        Load high scores from file.
        
        Returns:
            List of high score entries, empty list if file doesn't exist
        """
        try:
            if not self.scores_file.exists():
                self.high_scores = []
                return self.high_scores
            
            with open(self.scores_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
            
            if isinstance(data, list):
                self.high_scores = data
            else:
                print("WARNING: High scores file format invalid")
                self.high_scores = []
            
            return self.high_scores
        
        except json.JSONDecodeError:
            print("WARNING: High scores file corrupted, starting fresh")
            self.high_scores = []
            return self.high_scores
        
        except Exception as e:
            print(f"WARNING: Failed to load scores: {e}")
            self.high_scores = []
            return self.high_scores
    
    def get_high_scores(self, difficulty: Optional[str] = None) -> List[Dict]:
        """
        Get high scores, optionally filtered by difficulty.
        
        Args:
            difficulty: Optional difficulty filter
        
        Returns:
            List of high score entries
        """
        try:
            if difficulty:
                return [s for s in self.high_scores if s.get("difficulty") == difficulty]
            return self.high_scores
        
        except Exception as e:
            print(f"WARNING: Failed to get scores: {e}")
            return []
    
    def get_rank(self, score: int) -> int:
        """Get rank position for a given score (1-indexed)"""
        try:
            for i, entry in enumerate(self.high_scores):
                if score > entry["score"]:
                    return i + 1
            return len(self.high_scores) + 1
        
        except Exception:
            return 1
    
    def is_high_score(self, score: int) -> bool:
        """Check if score qualifies for high scores list"""
        try:
            if len(self.high_scores) < self.MAX_HIGH_SCORES:
                return True
            return score > self.high_scores[-1]["score"]
        
        except Exception:
            return False
    
    def clear_scores(self) -> bool:
        """Clear all high scores"""
        try:
            self.high_scores = []
            return self._write_scores_to_file()
        
        except Exception as e:
            print(f"WARNING: Failed to clear scores: {e}")
            return False
    
    def _write_scores_to_file(self) -> bool:
        """Write scores to persistent storage"""
        try:
            with open(self.scores_file, 'w', encoding='utf-8') as f:
                json.dump(self.high_scores, f, indent=2, ensure_ascii=False)
            return True
        
        except Exception as e:
            print(f"WARNING: Failed to write scores: {e}")
            return False
    
    def get_top_scores(self, count: int = 5) -> List[Dict]:
        """Get top N scores"""
        try:
            return self.high_scores[:min(count, len(self.high_scores))]
        
        except Exception:
            return []
    
    def get_player_best(self, player_name: str) -> Optional[Dict]:
        """Get best score for a specific player"""
        try:
            for entry in self.high_scores:
                if entry.get("name", "").lower() == player_name.lower():
                    return entry
            return None
        
        except Exception:
            return None
    
    def export_scores(self, filepath: str) -> bool:
        """Export scores to CSV file"""
        try:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write("Rank,Player,Score,Difficulty,Date\n")
                for i, entry in enumerate(self.high_scores, 1):
                    f.write(f"{i},{entry.get('name','Unknown')},{entry.get('score',0)},{entry.get('difficulty','')},{entry.get('date','')}\n")
            return True
        
        except Exception as e:
            print(f"WARNING: Failed to export scores: {e}")
            return False


if __name__ == "__main__":
    # Example usage
    print("=== MathBlat Score Manager (Python Backup) ===\n")
    
    manager = ScoreManager()
    
    # Add some test scores
    test_scores = [
        ("Alice", 150, "HARD"),
        ("Bob", 120, "MEDIUM"),
        ("Charlie", 100, "EASY"),
        ("Diana", 180, "HARD"),
        ("Eve", 90, "MEDIUM"),
    ]
    
    for name, score, difficulty in test_scores:
        if manager.save_score(name, score, difficulty):
            print(f"✅ Saved: {name} - {score} ({difficulty})")
        else:
            print(f"❌ Failed to save: {name}")
    
    print("\n=== High Scores ===")
    for i, score in enumerate(manager.get_high_scores(), 1):
        print(f"{i}. {score['name']}: {score['score']} ({score['difficulty']}) - {score['date']}")
    
    print(f"\nScores file: {manager.scores_file}")
