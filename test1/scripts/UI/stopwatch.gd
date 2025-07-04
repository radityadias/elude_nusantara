extends Node
class_name Stopwatch

var time: float = 0.0
var stopped: bool = false

func _ready() -> void:
	GameManager.game_finished.connect(finish)
	set_process(false)

func _process(delta: float) -> void:
	if not stopped:
		time += delta

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("move_left") or event.is_action_pressed('move_right') or event.is_action_pressed("jump"):
		set_process(true)

func finish() -> void:
	set_process(false)
	stopped = true
	var last_time = time_to_string()

func reset() -> void:
	time = 0.0

func pause() -> void:
	stopped = true

func resume() -> void:
	stopped = false

func time_to_string() -> String:
	var minutes: int = int(time / 60)
	var seconds: int = int(fmod(time, 60))
	var milliseconds: int = int(fmod(time, 1.0) * 1000.0)
	return "%02d : %02d : %03d" % [minutes, seconds, milliseconds]

func get_raw_time() -> float:
	return time

func time_string_to_float(time_str: String) -> float:
	var parts = time_str.split(":")
	if parts.size() != 3:
		return 0.0  # Fallback if format is wrong
	
	var minutes = int(parts[0])
	var seconds = int(parts[1])
	var milliseconds = int(parts[2])
	
	return minutes * 60.0 + seconds + milliseconds / 1000.0
