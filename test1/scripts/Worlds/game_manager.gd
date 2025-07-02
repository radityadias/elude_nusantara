extends Node

# ======= SIGNALS =======
signal cards_changed(card_type: String, count: int)
signal scanner_validated(card_type: String, success: bool)
signal counted_stars(value: int)
signal game_finished
signal game_pause
signal took_damage
signal box_reseted
signal jumppad_used
signal player_died

# ======= NODES =======
@onready var stopwatch: Stopwatch = get_tree().get_first_node_in_group("stopwatch")
@onready var delay: Timer = $Delay


# ======= STATE =======
var collected_cards: Dictionary = {}
var cards_collected: int = 0
var is_having_card: bool = false
var player_is_dead: bool = false
var current_level_data: LevelData
var base_path: String = "res://scenes/levels/level_"
var level_data_base_path: String = "res://scripts/Levels/Data/Level Data/level_"

# ======= READY =======
func _ready() -> void:
	reset_game_state()
	var player = get_tree().get_first_node_in_group("player")

# ======= PROCESS =======
func _process(delta: float) -> void:
	if stopwatch == null or not is_instance_valid(stopwatch):
		stopwatch = get_tree().get_first_node_in_group("stopwatch")

# ======= LEVEL SYSTEM =======
func handle_stars(value: int) -> void:
	counted_stars.emit(value)

func set_current_level_data(current_data: LevelData) -> void:
	current_level_data = current_data

func next_level() -> void:
	var next_level_id = current_level_data.level_id + 1
	var target_level_path = base_path + str(next_level_id) + ".tscn"
	var target_level_data_path = level_data_base_path + str(next_level_id) + "_data.tres"
	current_level_data  = load(target_level_data_path)
	SceneManager.change_scene(target_level_path)

# ======= GAME FLOW =======
func game_finish() -> void:
	game_finished.emit()

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("Escape"):
		game_pause.emit()

func game_end() -> void:
	get_tree().quit()

func game_restart() -> void:
	reset_game_state()
	get_tree().reload_current_scene()

# ======= EVENTS =======
func player_damaged() -> void:
	took_damage.emit()

func player_dead() -> void:
	player_is_dead = true
	player_died.emit()

func using_jumppad() -> void:
	jumppad_used.emit()

func box_reset() -> void:
	box_reseted.emit()

# ======= CARD SYSTEM =======
func add_card(card_type: String) -> void:
	collected_cards[card_type] = collected_cards.get(card_type, 0) + 1
	cards_changed.emit(card_type, collected_cards[card_type])
	print("Collected %s key. Total %s %s keys." % [card_type, collected_cards[card_type], card_type]) # For debugging

func has_card(card_type: String, required_count: int = 1) -> bool:
	return collected_cards.get(card_type, 0) >= required_count

func consume_card(card_type: String, count: int = 1) -> void:
	if collected_cards.has(card_type):
		collected_cards[card_type] -= count
		if collected_cards[card_type] <= 0:
			collected_cards.erase(card_type)
		cards_changed.emit(card_type, collected_cards.get(card_type, 0))
		print("Consumed %s %s key. Remaining %s %s keys." % [count, card_type, collected_cards.get(card_type, 0), card_type]) # For debugging

func validate_scan(card_type: String, required_count: int = 1) -> void:
	if has_card(card_type, required_count):
		scanner_validated.emit(card_type, true)
	else:
		scanner_validated.emit(card_type, false)

# ======= STOPWATCH SYSTEM =======
func get_stopwatch_time_string() -> String:
	if stopwatch == null or not is_instance_valid(stopwatch):
		return "00:00:000"
	return stopwatch.time_to_string()

func get_stopwatch_raw_time() -> float:
	if stopwatch == null or not is_instance_valid(stopwatch):
		return 0.0
	var player_time: String = stopwatch.time_to_string()
	return stopwatch.time_string_to_float(player_time)

# ======= RESET =======
func reset_game_state() -> void:
	collected_cards.clear()
	is_having_card = false
	player_is_dead = false
