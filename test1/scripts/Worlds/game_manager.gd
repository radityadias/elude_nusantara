extends Node

# ======= SIGNALS =======
signal cards_changed(value: int)
signal scanner_validated(value: bool)
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
var cards_collected: int = 0
var is_having_card: bool = false
var player_is_dead: bool = false

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
func add_card() -> void:
	cards_collected += 1
	cards_changed.emit(cards_collected)
	
func validate_scan() -> void:
	if cards_collected > 0:
		is_having_card = true
		scanner_validated.emit(true)
	else:
		scanner_validated.emit(false)

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
	cards_collected = 0
	is_having_card = false
	player_is_dead = false
