extends Node

signal cards_changed(value: int)
signal scanner_validated(value: bool)
signal game_finished
signal took_damaged
signal box_reseted

@onready var stopwatch: Stopwatch = get_tree().get_first_node_in_group("stopwatch")
@onready var delay: Timer = $Delay

var cards_collected : int = 0
var is_having_card: bool = false

func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	
	if player:
		if player and not took_damaged.is_connected(player.decrease_health):
			took_damaged.connect(player.decrease_health)
	else:
		print("player not found")
		return

func _process(delta: float) -> void:
	if stopwatch == null or !is_instance_valid(stopwatch):
		stopwatch = get_tree().get_first_node_in_group("stopwatch")

func player_damaged() -> void:
	took_damaged.emit()

func add_card():
	cards_collected += 1
	cards_changed.emit(cards_collected)

func validate_scan():
	if cards_collected > 0:
		is_having_card = true
		scanner_validated.emit(true)
	else:
		scanner_validated.emit(false)

func start_stopwatch() -> void:
	if stopwatch:
		print("stopwatch start")

func pause_stopwatch() -> void:
	if stopwatch:
		print("stopwatch pause")

func reset_stopwatch() -> void:
	if stopwatch:
		print("stopwatch reset")

func get_stopwatch_time_string() -> String:
	if stopwatch == null or !is_instance_valid(stopwatch):
		return "00:00:000"
		
	return stopwatch.time_to_string()

func game_finish() -> void:
	game_finished.emit()

func game_end() -> void:
	get_tree().quit()

func game_restart() -> void:
	get_tree().reload_current_scene()

func box_reset() -> void:
	box_reseted.emit()
