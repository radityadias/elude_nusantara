extends Node

var cards_collected : int = 0
var is_having_card: bool = false
var health = 3

signal cards_changed(value: int)
signal scanner_validated(value: bool)

func decrease_health() -> void:
	health -= 1
	print(health)
	
	if health == 0 :
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
