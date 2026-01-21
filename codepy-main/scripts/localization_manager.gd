extends Node

## Localization Manager - Handles multi-language support for the game
## Supports: English, Spanish, French (easily extensible)

class_name LocalizationManager

var current_language: String = "en"
var translations: Dictionary = {}
var _current_translation_dict: Dictionary = {} # Cache for faster lookups

func _ready() -> void:
	try:
		_initialize_translations()
		# Load saved language preference
		var saved_lang = ConfigFileHandler.load_setting("game", "language", "en") if ConfigFileHandler else "en"
		set_language(saved_lang)
	except:
		# Fallback: Initialize English-only if initialization fails
		print("WARNING: LocalizationManager initialization failed, using English-only mode")
		_initialize_translations()
		set_language("en")

## Initialize all translation dictionaries
func _initialize_translations() -> void:
	translations = {
		"en": {
			# Menu strings
			"main_menu_title": "MathBlat",
			"single_player": "Single-Player",
			"host": "Host Game",
			"join": "Join Game",
			"difficulty": "Difficulty",
			"easy": "Easy",
			"medium": "Medium",
			"hard": "Hard",
			"settings": "Settings",
			"language": "Language",
			"volume": "Volume",
			"quit": "Quit",
			"back": "Back",
			"resume": "Resume",
			"pause": "Paused",
			
			# Game strings
			"your_score": "Your Score",
			"opponent_score": "Opponent Score",
			"correct": "Correct! +%d",
			"wrong": "Wrong! Answer: %d",
			"times_up": "Time's up! Answer: %d",
			"streak": "Streak: %d",
			"combo": "Combo x%d!",
			"combo_bonus": "Combo Bonus +%d",
			"power_up_active": "Power-Up: %s",
			
			# Victory strings
			"victory": "Victory!",
			"you_win": "You Win!",
			"opponent_wins": "Opponent Wins!",
			"new_high_score": "New High Score!",
			"final_score": "Final Score: %d",
			"leaderboard": "Leaderboard",
			
			# Engagement strings
			"achievement_unlocked": "Achievement Unlocked: %s",
			"achievement_first_win": "First Win",
			"achievement_perfect_game": "Perfect Game",
			"achievement_speed_demon": "Speed Demon",
			"achievement_combo_master": "Combo Master",
			"level": "Level",
			"experience": "XP",
		},
		"es": {
			# Menu strings
			"main_menu_title": "MathBlat",
			"single_player": "Un Jugador",
			"host": "Crear Partida",
			"join": "Unirse a Partida",
			"difficulty": "Dificultad",
			"easy": "Fácil",
			"medium": "Medio",
			"hard": "Difícil",
			"settings": "Configuración",
			"language": "Idioma",
			"volume": "Volumen",
			"quit": "Salir",
			"back": "Atrás",
			"resume": "Reanudar",
			"pause": "Pausado",
			
			# Game strings
			"your_score": "Tu Puntuación",
			"opponent_score": "Puntuación del Oponente",
			"correct": "¡Correcto! +%d",
			"wrong": "¡Incorrecto! Respuesta: %d",
			"times_up": "¡Se acabó el tiempo! Respuesta: %d",
			"streak": "Racha: %d",
			"combo": "¡Combo x%d!",
			"combo_bonus": "Bonus Combo +%d",
			"power_up_active": "Power-Up: %s",
			
			# Victory strings
			"victory": "¡Victoria!",
			"you_win": "¡Ganaste!",
			"opponent_wins": "¡El Oponente Ganó!",
			"new_high_score": "¡Nueva Puntuación Máxima!",
			"final_score": "Puntuación Final: %d",
			"leaderboard": "Tabla de Clasificación",
			
			# Engagement strings
			"achievement_unlocked": "Logro Desbloqueado: %s",
			"achievement_first_win": "Primera Victoria",
			"achievement_perfect_game": "Juego Perfecto",
			"achievement_speed_demon": "Demonio de Velocidad",
			"achievement_combo_master": "Maestro de Combos",
			"level": "Nivel",
			"experience": "EXP",
		},
		"fr": {
			# Menu strings
			"main_menu_title": "MathBlat",
			"single_player": "Un Joueur",
			"host": "Créer une Partie",
			"join": "Rejoindre une Partie",
			"difficulty": "Difficulté",
			"easy": "Facile",
			"medium": "Moyen",
			"hard": "Difficile",
			"settings": "Paramètres",
			"language": "Langue",
			"volume": "Volume",
			"quit": "Quitter",
			"back": "Retour",
			"resume": "Reprendre",
			"pause": "En Pause",
			
			# Game strings
			"your_score": "Votre Score",
			"opponent_score": "Score de l'Adversaire",
			"correct": "Correct ! +%d",
			"wrong": "Incorrect ! Réponse : %d",
			"times_up": "Temps écoulé ! Réponse : %d",
			"streak": "Série: %d",
			"combo": "Combo x%d !",
			"combo_bonus": "Bonus Combo +%d",
			"power_up_active": "Power-Up: %s",
			
			# Victory strings
			"victory": "Victoire !",
			"you_win": "Vous Avez Gagné !",
			"opponent_wins": "L'Adversaire a Gagné !",
			"new_high_score": "Nouveau Meilleur Score !",
			"final_score": "Score Final: %d",
			"leaderboard": "Classement",
			
			# Engagement strings
			"achievement_unlocked": "Succès Débloqué: %s",
			"achievement_first_win": "Première Victoire",
			"achievement_perfect_game": "Partie Parfaite",
			"achievement_speed_demon": "Démon de Vitesse",
			"achievement_combo_master": "Maître des Combos",
			"level": "Niveau",
			"experience": "EXP",
		}
	}

## Set the current language
func set_language(language_code: String) -> void:
	try:
		if not language_code or language_code.is_empty():
			print("WARNING: set_language received empty language_code, using 'en'")
			language_code = "en"
		
		if language_code in translations:
			current_language = language_code
			_current_translation_dict = translations[language_code]
			
			if ConfigFileHandler:
				try:
					ConfigFileHandler.save_setting("game", "language", language_code)
				except:
					print("WARNING: Failed to save language preference for '%s'" % language_code)
			language_changed.emit()
		else:
			# Fallback to English if language not found
			print("WARNING: Language '%s' not found, falling back to English" % language_code)
			current_language = "en"
			if "en" in translations:
				_current_translation_dict = translations["en"]
			else:
				print("ERROR: English language not found in translations!")
				_current_translation_dict = {}
			language_changed.emit()
	except:
		print("ERROR: set_language failed, defaulting to English")
		current_language = "en"
		_current_translation_dict = translations.get("en", {})

## Get translated string with safe fallback handling
## First tries current language, then English, then default text
func get_text(key: String, default_text: String = "") -> String:
	try:
		if not key or key.is_empty():
			print("WARNING: get_text received empty key")
			return default_text
		
		# Try current language
		if _current_translation_dict and key in _current_translation_dict:
			return _current_translation_dict[key]
			
		# Fallback to English if not found in current language (and current isn't English)
		if current_language != "en" and "en" in translations and key in translations["en"]:
			return translations["en"][key]
			
		return default_text
	except:
		print("ERROR: get_text failed for key '%s'" % key)
		return default_text

## Get formatted translated string with variable substitution
## Handles format string errors gracefully
func get_text_formatted(key: String, args: Array = []) -> String:
	try:
		var text = get_text(key, key)  # Use key as fallback if translation missing
		if args.size() > 0:
			text = text % args
		return text
	except:
		print("ERROR: get_text_formatted failed for key '%s'" % key)
		if args.size() > 0:
			return (key % args) if key.contains("%") else key
		return key

## Get list of available languages
func get_available_languages() -> Array[String]:
	try:
		return ["en", "es", "fr"]
	except:
		print("ERROR: get_available_languages failed, returning English only")
		return ["en"]

## Get language display name
func get_language_name(language_code: String) -> String:
	try:
		if not language_code or language_code.is_empty():
			print("WARNING: get_language_name received empty language_code")
			return "Unknown"
		
		var names = {
			"en": "English",
			"es": "Español",
			"fr": "Français"
		}
		return names.get(language_code, language_code)
	except:
		print("ERROR: get_language_name failed for '%s'" % language_code)
		return language_code

signal language_changed
