extends Node
class_name Stopwatch

var time: float = 0.0
var stopped: bool = false

func _process(delta: float) -> void:
	if not stopped:
		time += delta

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
