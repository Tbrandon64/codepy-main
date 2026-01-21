extends Node

## Localization Manager - Handles multi-language support for the game
## Supports: English, Spanish, French (easily extensible)

class_name LocalizationManager

var current_language: String = "en"
var translations: Dictionary = {}

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
		current_language = "en"

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
	if language_code in translations:
		current_language = language_code
		if ConfigFileHandler:
			try:
				ConfigFileHandler.save_setting("game", "language", language_code)
			except:
				print("WARNING: Failed to save language preference")
		language_changed.emit()
	else:
		# Fallback to English if language not found
		print("WARNING: Language '%s' not found, falling back to English" % language_code)
		current_language = "en"
		language_changed.emit()

## Get a translated string
func get_text(key: String, default_text: String = "") -> String:
	if current_language in translations and key in translations[current_language]:
		return translations[current_language][key]
	# Fallback to English
	if "en" in translations and key in translations["en"]:
		return translations["en"][key]
	return default_text

## Get a translated string with formatted parameters
func get_text_formatted(key: String, args: Array = []) -> String:
	var text = get_text(key)
	if args.size() > 0:
		return text % args
	return text

## Get list of available languages
func get_available_languages() -> Array[String]:
	return ["en", "es", "fr"]

## Get language display name
func get_language_name(language_code: String) -> String:
	var names = {
		"en": "English",
		"es": "Español",
		"fr": "Français"
	}
	return names.get(language_code, language_code)

signal language_changed
