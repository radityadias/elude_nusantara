extends Node
class_name LevelManager

@export var finish_ui: PackedScene
@export var gameover_ui: PackedScene
@export var pause_ui: PackedScene
@export var level_bgm_path: String = "res://assets/SFX ELUDE/BGM/IN GAME (sementara).mp3" 

var current_active_ui: Control = null

@export var level_data: LevelData

func _ready() -> void:
	reset()
	if level_data == null:
		push_warning("LevelData is not assigned to LevelManager!")

	GameManager.game_finished.connect(_on_player_finished)
	GameManager.took_damage.connect(_on_player_damaged)
	GameManager.player_died.connect(_on_player_died)
	GameManager.game_pause.connect(show_pause_ui)
	 # Pastikan AudioManager tersedia
	if AudioManager:
		# 1. Hentikan BGM yang sedang berjalan (dari scene sebelumnya)
		AudioManager.stop_music()
		print("BGM stopped upon entering level scene.")

		
		AudioManager.play_music(level_bgm_path, -15.0) # Sesuaikan volume sesuai kebutuhan
	else:
		print("ERROR: AudioManager AutoLoad not found!")
	

func _on_player_damaged() -> void:
	if level_data:
		level_data.player_damaged = true

func _on_player_died() -> void:
	show_gameover_ui()

func _on_player_finished() -> void:
	if level_data:
		level_data.stage_finished = true
		level_data.player_time = GameManager.get_stopwatch_raw_time()
		level_data.player_time_string = GameManager.get_stopwatch_time_string()
		level_data.target_time_reached = level_data.player_time <= level_data.time_target
		if calculate_stars() >= level_data.total_stars:
			level_data.total_stars = calculate_stars()
		level_data.level_cleared = true
		save_level_data(level_data)

		show_finish_ui()

func save_level_data(data: LevelData) -> void:
	if data.resource_path.is_empty():
		push_warning("LevelData resource has no path. Cannot save.")
		return
	
	var error = ResourceSaver.save(data, data.resource_path)
	if error != OK:
		push_error("Error saving LevelData to %s: %s" % [data.resource_path, error])
	else:
		print("LevelData saved successfully to: ", data.resource_path)

func show_gameover_ui() -> void:
	if current_active_ui != null and is_instance_valid(current_active_ui):
		current_active_ui.queue_free()
		current_active_ui = null 

	var gameover_instance = gameover_ui.instantiate()
	var ui_root_layer = get_tree().get_first_node_in_group("callable_ui")
	if ui_root_layer:
		ui_root_layer.add_child(gameover_instance)
		current_active_ui = gameover_instance
	else:
		print("No node found in 'callable ui' group ")
		push_error("No node found in 'callable ui' group")

func show_finish_ui() -> void:
	
	if current_active_ui != null and is_instance_valid(current_active_ui):
		current_active_ui.queue_free()
		current_active_ui = null 

	var finish_instance = finish_ui.instantiate()
	if finish_instance is StageComplete:
		(finish_instance as StageComplete).set_initial_stars(calculate_stars())
	var ui_root_layer = get_tree().get_first_node_in_group("callable_ui")
	if ui_root_layer:
		ui_root_layer.add_child(finish_instance)
		current_active_ui = finish_instance
	else:
		print("No node found in 'callable ui' group ")
		push_error("No node found in 'callable ui' group")

func show_pause_ui() -> void:
	if current_active_ui != null and is_instance_valid(current_active_ui):
		current_active_ui.queue_free()
		current_active_ui = null 
	
	var pause_instance = pause_ui.instantiate()
	var ui_root_layer = get_tree().get_first_node_in_group("callable_ui")
	if ui_root_layer:
		print("Node Found")
		ui_root_layer.add_child(pause_instance)
		current_active_ui = pause_instance
	else:
		print("No node found in 'callable ui' group ")
		push_error("No node found in 'callable ui' group")

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

func reset() -> void:
	level_data.player_damaged = false
	level_data.target_time_reached = false
	level_data.stage_finished = false
