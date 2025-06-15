extends Area2D

@onready var interaction_area: InteractionArea = $InteractionArea

@export var required_cards: int = 1
const text_to_display : String = "[E] to interact"
const unlock_message : String = "Door Unlocked!"
var is_scanned : bool = false

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact():
	if GameManager.cards_collected == 0:
		interaction_area.message("You need a keycard")
	elif GameManager.cards_collected >= required_cards:
		GameManager.validate_scan()
		is_scanned = true
		interaction_area.message(unlock_message)

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if not is_scanned:
		InteractionManager.base_text = text_to_display
	else:
		InteractionManager.base_text = unlock_message
