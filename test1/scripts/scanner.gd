extends Area2D

@onready var interaction_area: InteractionArea = $InteractionArea
const lines: Array[String] = ["Scanner active"]
var required_cards: int = 1

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	if GameManager.cards_collected == 0:
		interaction_area.message("You need a keycard")
	else:
		GameManager.validate_scan()
		interaction_area.message("Door Unlocked!")
