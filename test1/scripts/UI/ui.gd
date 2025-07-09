extends Control

@onready var stopwatch_label: Label = $CanvasLayer/Timer/HBoxContainer/Label

var is_card_used : bool = false
var input_pressed: bool = false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	stopwatch_label.text = GameManager.get_stopwatch_time_string()

func _unhandled_input(event: InputEvent) -> void:
	if not input_pressed and event.is_action_pressed("move_left") or event.is_action_pressed('move_right'):
		input_pressed = true
