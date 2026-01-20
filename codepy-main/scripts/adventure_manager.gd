extends Node

## Adventure Manager - Handles adventure mode progression and dungeon management
## Minecraft Dungeons-style progression with map navigation

class Dungeon:
	var id: int
	var name: String
	var difficulty: String  # "easy", "medium", "hard"
	var level: int  # 1-20 difficulty scaling
	var position: Vector2
	var cleared: bool
	var rewards: Dictionary
	var required_energy: int
	
	func _init(p_id: int, p_name: String, p_difficulty: String, p_level: int) -> void:
		id = p_id
		name = p_name
		difficulty = p_difficulty
		level = p_level
		position = Vector2.ZERO
		cleared = false
		rewards = {
			"energy": 0,
			"experience": 0,
			"loot": []
		}
		required_energy = p_level * 2

# Adventure progression data
var current_adventure: int = 0  # Current map/region index
var current_level: int = 1  # Overall adventure level
var total_levels_completed: int = 0
var dungeons: Array[Dungeon] = []
var map_seed: int = 0

# Map configuration
const DUNGEONS_PER_MAP: int = 5
const MAP_WIDTH: int = 800
const MAP_HEIGHT: int = 600
const DUNGEON_SPACING: float = 150.0

# Progression data
var experience: int = 0
var experience_to_next_level: int = 100

# Signals
signal adventure_started
signal dungeon_entered(dungeon: Dungeon)
signal dungeon_completed(dungeon: Dungeon, rewards: Dictionary)
signal adventure_level_up(new_level: int)
signal map_updated

func _ready() -> void:
	_load_adventure_data()
	if dungeons.is_empty():
		_generate_initial_adventure()

## Start a new adventure or continue existing
func start_adventure() -> void:
	if dungeons.is_empty():
		_generate_initial_adventure()
	emit_signal("adventure_started")

## Generate initial adventure map
func _generate_initial_adventure() -> void:
	# Seed the RNG for consistent dungeon placement
	map_seed = randi()
	seed(map_seed)
	
	dungeons.clear()
	
	# Create dungeons for this map
	for i in range(DUNGEONS_PER_MAP):
		var difficulty = _get_difficulty_for_position(i)
		var level = current_level + i
		var dungeon = Dungeon.new(i, "Dungeon %d" % (current_adventure * DUNGEONS_PER_MAP + i + 1), difficulty, level)
		
		# Position dungeons in a roughly linear path
		var x = 150 + (i * DUNGEON_SPACING)
		var y = randf_range(150.0, MAP_HEIGHT - 150.0)
		dungeon.position = Vector2(x, y)
		
		dungeons.append(dungeon)
	
	emit_signal("map_updated")
	_save_adventure_data()

## Get difficulty based on dungeon position
func _get_difficulty_for_position(position: int) -> String:
	match position:
		0, 1:
			return "easy"
		2, 3:
			return "medium"
		4:
			return "hard"
		_:
			return "medium"

## Get all dungeons for current map
func get_current_map_dungeons() -> Array[Dungeon]:
	return dungeons

## Get a specific dungeon
func get_dungeon(dungeon_id: int) -> Dungeon:
	for dungeon in dungeons:
		if dungeon.id == dungeon_id:
			return dungeon
	return null

## Check if player can enter a dungeon
func can_enter_dungeon(dungeon_id: int) -> bool:
	var dungeon = get_dungeon(dungeon_id)
	if dungeon == null:
		return false
	
	# Check if previous dungeon is cleared (except for first)
	if dungeon_id > 0:
		var previous = get_dungeon(dungeon_id - 1)
		if previous and not previous.cleared:
			return false
	
	# Check energy requirement
	var required_energy = dungeon.required_energy
	if FeatureConfig.energy_system_enabled:
		return EnergySystem.has_enough_energy(required_energy)
	
	return true

## Enter a dungeon
func enter_dungeon(dungeon_id: int) -> bool:
	var dungeon = get_dungeon(dungeon_id)
	if dungeon == null or not can_enter_dungeon(dungeon_id):
		return false
	
	# Consume energy if enabled
	if FeatureConfig.energy_system_enabled:
		var cost = int(dungeon.required_energy * FeatureConfig.get_energy_cost_multiplier())
		if not EnergySystem.consume_energy(cost, "adventure_dungeon"):
			return false
	
	emit_signal("dungeon_entered", dungeon)
	return true

## Complete a dungeon with rewards
func complete_dungeon(dungeon_id: int, score: int, time_taken: float) -> void:
	var dungeon = get_dungeon(dungeon_id)
	if dungeon == null:
		return
	
	dungeon.cleared = true
	total_levels_completed += 1
	
	# Calculate rewards based on performance
	var energy_reward = _calculate_energy_reward(dungeon, score)
	var experience_reward = _calculate_experience_reward(dungeon, score, time_taken)
	
	dungeon.rewards["energy"] = energy_reward
	dungeon.rewards["experience"] = experience_reward
	
	# Grant rewards
	if FeatureConfig.energy_system_enabled:
		EnergySystem.gain_energy(energy_reward, "dungeon_completion")
	
	gain_experience(experience_reward)
	
	emit_signal("dungeon_completed", dungeon, dungeon.rewards)
	
	# Check if map is complete
	if _is_map_complete():
		_advance_adventure()
	
	_save_adventure_data()

## Calculate energy reward
func _calculate_energy_reward(dungeon: Dungeon, score: int) -> int:
	var base_reward = 10
	
	# Difficulty multiplier
	var multiplier = 1.0
	match dungeon.difficulty:
		"easy":
			multiplier = 0.8
		"medium":
			multiplier = 1.0
		"hard":
			multiplier = 1.5
	
	# Score bonus (max score is 100)
	var score_multiplier = float(score) / 100.0
	
	return int(base_reward * multiplier * score_multiplier)

## Calculate experience reward
func _calculate_experience_reward(dungeon: Dungeon, score: int, time_taken: float) -> int:
	var base_exp = 20
	
	# Difficulty multiplier
	var multiplier = 1.0
	match dungeon.difficulty:
		"easy":
			multiplier = 1.0
		"medium":
			multiplier = 1.5
		"hard":
			multiplier = 2.0
	
	# Score bonus
	var score_bonus = int((float(score) / 100.0) * 10.0)
	
	# Time efficiency bonus (faster = more bonus, capped at 15 seconds)
	var time_bonus = max(0, int((15.0 - time_taken) * 2.0))
	
	return int((base_exp + score_bonus + time_bonus) * multiplier)

## Gain experience points
func gain_experience(amount: int) -> void:
	experience += amount
	
	# Check for level up
	while experience >= experience_to_next_level:
		experience -= experience_to_next_level
		current_level += 1
		experience_to_next_level = int(experience_to_next_level * 1.5)
		emit_signal("adventure_level_up", current_level)
	
	_save_adventure_data()

## Check if current map is fully cleared
func _is_map_complete() -> bool:
	for dungeon in dungeons:
		if not dungeon.cleared:
			return false
	return true

## Advance to next adventure map
func _advance_adventure() -> void:
	current_adventure += 1
	_generate_initial_adventure()

## Get player's adventure level
func get_adventure_level() -> int:
	return current_level

## Get current experience progress to next level
func get_experience_progress() -> Dictionary:
	return {
		"current": experience,
		"required": experience_to_next_level,
		"percentage": float(experience) / float(experience_to_next_level)
	}

## Get adventure summary
func get_adventure_summary() -> Dictionary:
	var cleared_count = 0
	for dungeon in dungeons:
		if dungeon.cleared:
			cleared_count += 1
	
	return {
		"current_map": current_adventure,
		"current_level": current_level,
		"experience": experience,
		"total_levels_completed": total_levels_completed,
		"dungeons_cleared_this_map": cleared_count,
		"total_dungeons_this_map": DUNGEONS_PER_MAP
	}

## Reset adventure (for testing)
func reset_adventure() -> void:
	current_adventure = 0
	current_level = 1
	total_levels_completed = 0
	experience = 0
	experience_to_next_level = 100
	dungeons.clear()
	_generate_initial_adventure()

## Save adventure data
func _save_adventure_data() -> void:
	var dungeon_data = []
	for dungeon in dungeons:
		dungeon_data.append({
			"id": dungeon.id,
			"name": dungeon.name,
			"difficulty": dungeon.difficulty,
			"level": dungeon.level,
			"position": {"x": dungeon.position.x, "y": dungeon.position.y},
			"cleared": dungeon.cleared,
			"rewards": dungeon.rewards,
			"required_energy": dungeon.required_energy
		})
	
	var data = {
		"current_adventure": current_adventure,
		"current_level": current_level,
		"total_levels_completed": total_levels_completed,
		"experience": experience,
		"experience_to_next_level": experience_to_next_level,
		"map_seed": map_seed,
		"dungeons": dungeon_data
	}
	
	var json = JSON.stringify(data)
	var file = FileAccess.open("user://adventure_data.json", FileAccess.WRITE)
	if file:
		file.store_string(json)

## Load adventure data
func _load_adventure_data() -> void:
	if ResourceLoader.exists("user://adventure_data.json"):
		var file = FileAccess.open("user://adventure_data.json", FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			var json = JSON.new()
			if json.parse(json_string) == OK:
				var data = json.get_data()
				current_adventure = data.get("current_adventure", 0)
				current_level = data.get("current_level", 1)
				total_levels_completed = data.get("total_levels_completed", 0)
				experience = data.get("experience", 0)
				experience_to_next_level = data.get("experience_to_next_level", 100)
				map_seed = data.get("map_seed", 0)
				
				# Load dungeons
				dungeons.clear()
				var dungeon_data = data.get("dungeons", [])
				for d in dungeon_data:
					var dungeon = Dungeon.new(d["id"], d["name"], d["difficulty"], d["level"])
					dungeon.position = Vector2(d["position"]["x"], d["position"]["y"])
					dungeon.cleared = d["cleared"]
					dungeon.rewards = d["rewards"]
					dungeon.required_energy = d["required_energy"]
					dungeons.append(dungeon)
