#!/usr/bin/env python3
"""
MathBlat Configuration Manager - Python Backup
Fallback implementation for managing settings if Godot system fails.

Usage:
    from config_manager import ConfigManager
    config = ConfigManager()
    config.save_setting("Game", "Difficulty", "HARD")
    difficulty = config.load_setting("Game", "Difficulty", "EASY")
"""

import json
import os
from pathlib import Path
from typing import Any, Dict, Optional


class ConfigManager:
    """Manage game configuration with persistent JSON storage"""
    
    DEFAULT_CONFIG_DIR = Path.home() / ".mathblat"
    DEFAULT_CONFIG_FILE = DEFAULT_CONFIG_DIR / "config.json"
    
    # Default configuration structure
    DEFAULT_CONFIG = {
        "Game": {
            "Difficulty": "EASY",
            "LastPlayerName": "Player",
            "Volume": 1.0,
        },
        "Audio": {
            "MasterVolume": 1.0,
            "MusicVolume": 0.8,
            "SFXVolume": 1.0,
            "EnableSound": True,
        },
        "Graphics": {
            "Brightness": 1.0,
            "ShowParticles": True,
            "AnimationsEnabled": True,
        },
        "Localization": {
            "Language": "EN",
            "DateFormat": "YYYY-MM-DD",
        },
        "Player": {
            "TotalGamesPlayed": 0,
            "TotalScore": 0,
            "LastPlayedDate": "",
        },
    }
    
    def __init__(self, config_file: Optional[str] = None):
        """Initialize config manager with optional custom file path"""
        try:
            if config_file:
                self.config_file = Path(config_file)
            else:
                self.config_file = self.DEFAULT_CONFIG_FILE
            
            # Create directory if needed
            self.config_file.parent.mkdir(parents=True, exist_ok=True)
            
            self.config: Dict = {}
            self.load_config()
        
        except Exception as e:
            print(f"WARNING: Failed to initialize ConfigManager: {e}")
            self.config = self.DEFAULT_CONFIG.copy()
    
    def load_config(self) -> bool:
        """
        Load configuration from file.
        
        Returns:
            True if loaded successfully, False if using defaults
        """
        try:
            if not self.config_file.exists():
                # First time setup
                self.config = self._deep_copy(self.DEFAULT_CONFIG)
                self.save_config()
                return True
            
            with open(self.config_file, 'r', encoding='utf-8') as f:
                loaded_config = json.load(f)
            
            # Merge with defaults to ensure all keys exist
            self.config = self._merge_configs(self.DEFAULT_CONFIG, loaded_config)
            return True
        
        except json.JSONDecodeError:
            print("WARNING: Config file corrupted, using defaults")
            self.config = self._deep_copy(self.DEFAULT_CONFIG)
            return False
        
        except Exception as e:
            print(f"WARNING: Failed to load config: {e}")
            self.config = self._deep_copy(self.DEFAULT_CONFIG)
            return False
    
    def save_config(self) -> bool:
        """Save current configuration to file"""
        try:
            with open(self.config_file, 'w', encoding='utf-8') as f:
                json.dump(self.config, f, indent=2, ensure_ascii=False)
            return True
        
        except Exception as e:
            print(f"WARNING: Failed to save config: {e}")
            return False
    
    def load_setting(self, category: str, key: str, default: Any = None) -> Any:
        """
        Load a specific setting.
        
        Args:
            category: Configuration category
            key: Setting key
            default: Default value if setting not found
        
        Returns:
            Setting value or default
        """
        try:
            if category in self.config and key in self.config[category]:
                return self.config[category][key]
            return default
        
        except Exception as e:
            print(f"WARNING: Failed to load setting {category}.{key}: {e}")
            return default
    
    def save_setting(self, category: str, key: str, value: Any) -> bool:
        """
        Save a specific setting.
        
        Args:
            category: Configuration category
            key: Setting key
            value: Value to save
        
        Returns:
            True if saved successfully
        """
        try:
            if category not in self.config:
                self.config[category] = {}
            
            self.config[category][key] = value
            return self.save_config()
        
        except Exception as e:
            print(f"WARNING: Failed to save setting {category}.{key}: {e}")
            return False
    
    def get_category(self, category: str) -> Dict:
        """Get all settings in a category"""
        try:
            return self.config.get(category, {})
        
        except Exception:
            return {}
    
    def set_category(self, category: str, settings: Dict) -> bool:
        """Set all settings in a category"""
        try:
            self.config[category] = settings
            return self.save_config()
        
        except Exception as e:
            print(f"WARNING: Failed to set category {category}: {e}")
            return False
    
    def reset_to_defaults(self) -> bool:
        """Reset all configuration to defaults"""
        try:
            self.config = self._deep_copy(self.DEFAULT_CONFIG)
            return self.save_config()
        
        except Exception as e:
            print(f"WARNING: Failed to reset config: {e}")
            return False
    
    def export_config(self, filepath: str) -> bool:
        """Export configuration to a file"""
        try:
            with open(filepath, 'w', encoding='utf-8') as f:
                json.dump(self.config, f, indent=2, ensure_ascii=False)
            return True
        
        except Exception as e:
            print(f"WARNING: Failed to export config: {e}")
            return False
    
    def import_config(self, filepath: str) -> bool:
        """Import configuration from a file"""
        try:
            with open(filepath, 'r', encoding='utf-8') as f:
                imported = json.load(f)
            
            self.config = self._merge_configs(self.DEFAULT_CONFIG, imported)
            return self.save_config()
        
        except Exception as e:
            print(f"WARNING: Failed to import config: {e}")
            return False
    
    def get_all(self) -> Dict:
        """Get entire configuration"""
        return self._deep_copy(self.config)
    
    @staticmethod
    def _deep_copy(obj: Dict) -> Dict:
        """Create a deep copy of a dictionary"""
        try:
            return json.loads(json.dumps(obj))
        except Exception:
            return obj.copy()
    
    @staticmethod
    def _merge_configs(defaults: Dict, loaded: Dict) -> Dict:
        """Merge loaded config with defaults, preserving structure"""
        try:
            merged = ConfigManager._deep_copy(defaults)
            
            for category, settings in loaded.items():
                if isinstance(settings, dict):
                    if category not in merged:
                        merged[category] = {}
                    merged[category].update(settings)
                else:
                    merged[category] = settings
            
            return merged
        
        except Exception:
            return defaults


if __name__ == "__main__":
    # Example usage
    print("=== MathBlat Configuration Manager (Python Backup) ===\n")
    
    config = ConfigManager()
    
    # Load and display settings
    print("Current Configuration:")
    print(f"  Difficulty: {config.load_setting('Game', 'Difficulty', 'EASY')}")
    print(f"  Master Volume: {config.load_setting('Audio', 'MasterVolume', 1.0)}")
    print(f"  Language: {config.load_setting('Localization', 'Language', 'EN')}")
    
    # Save new settings
    print("\nSaving new settings...")
    config.save_setting("Game", "Difficulty", "HARD")
    config.save_setting("Audio", "MasterVolume", 0.7)
    config.save_setting("Localization", "Language", "ES")
    
    print("Updated Configuration:")
    print(f"  Difficulty: {config.load_setting('Game', 'Difficulty')}")
    print(f"  Master Volume: {config.load_setting('Audio', 'MasterVolume')}")
    print(f"  Language: {config.load_setting('Localization', 'Language')}")
    
    print(f"\nConfig file: {config.config_file}")
