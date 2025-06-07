extends Control

@onready var stopwatch_label: Label = $CanvasLayer/Timer/HBoxContainer/Label

func _process(delta: float) -> void:
	stopwatch_label.text = GameManager.get_stopwatch_time_string()
