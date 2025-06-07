extends Node

signal cards_changed(value: int)
signal scanner_validated(value: bool)

@export var hearths: Array[Node]

var cards_collected : int = 0
var is_having_card: bool = false
var lives: int = 3

func decrease_health() -> void:
	lives -= 1
	
	for h in 3:
		if h < lives:
			hearths[h].show	()
		else:
			hearths[h].hide()
	
	if lives == 0:
		get_tree().reload_current_scene()

func add_card():
	cards_collected += 1
	cards_changed.emit(cards_collected)

func validate_scan():
	if cards_collected > 0:
		is_having_card = true
		scanner_validated.emit(true)
	else:
		scanner_validated.emit(false)
