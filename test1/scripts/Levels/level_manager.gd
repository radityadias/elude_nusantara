extends Node
class_name LevelManager

@export var level_data: LevelData

func _ready() -> void:
	if level_data == null:
		push_warning("LevelData is not assigned to LevelManager!")
	
	GameManager.game_finished.connect(_on_player_finished)
	GameManager.took_damage.connect(_on_player_damaged)

func _on_player_damaged() -> void:
	if level_data:
		level_data.player_damaged = true

func _on_player_finished() -> void:
	if level_data:
		level_data.stage_finished = true
		level_data.player_time = GameManager.get_stopwatch_raw_time()
		level_data.target_time_reached = level_data.player_time <= level_data.time_target
		level_data.total_stars = calculate_stars()
		GameManager.handle_stars(level_data.total_stars)

func calculate_stars() -> int:
	var stars_earned: int = 0
	
	# Star 1: Player finish the game
	if level_data.stage_finished:
		stars_earned += 1

	# Star 2: No Damage Star
	if not level_data.player_damaged:
		stars_earned += 1

	# Star 3: Time Target Star
	if level_data.target_time_reached:
		stars_earned += 1

	return stars_earned

func get_total_stars() -> int:
	if level_data:
		return level_data.total_stars
	return 0 
