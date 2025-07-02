extends Control

@onready var stopwatch_label: Label = $CanvasLayer/Timer/HBoxContainer/Label
@onready var card: Panel = $CanvasLayer/Card

var is_card_used : bool = false
var input_pressed: bool = false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	
	if input_pressed:
		stopwatch_label.text = GameManager.get_stopwatch_time_string()
	
	GameManager.cards_changed.connect(change_card_opacity)
	GameManager.scanner_validated.connect(card_used)

func _unhandled_input(event: InputEvent) -> void:
	if not input_pressed and event.is_action_pressed("move_left") or event.is_action_pressed('move_right'):
		input_pressed = true

func change_card_opacity(value) -> void:
	if value == 1:
		card.modulate.a = 1

func card_used(value: bool) -> void:
	if value and not is_card_used:
		is_card_used = true
		card.queue_free()
