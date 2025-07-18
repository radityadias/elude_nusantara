extends Area2D

@onready var interaction_area: InteractionArea = $InteractionArea

@export var required_cards: int = 1
@export var required_card_type: String = "default"

const text_to_display : String = "[E] to interact"
const unlock_message : String = "%s door Unlocked!"
const no_card_message: String = "You need a %s card"
var is_scanned : bool = false

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")
	
	if AudioManager == null:
		push_error("ERROR: AudioManager AutoLoad not found in ScannerLogic.gd!")

func _on_game_manager_scanner_validated(scanned_card_type: String, success: bool):
	if scanned_card_type == required_card_type:
		if success:
			is_scanned = true
			interaction_area.message(unlock_message)
			# ✅ SUCCESS SOUND
			if AudioManager:
				AudioManager.play_sfx(AudioManager.scanner_sound_path, -3.0, 1.1) # louder and normal pitch

			GameManager.consume_card(required_card_type, required_cards)
		else:
			is_scanned = false
			interaction_area.message(no_card_message % required_card_type.capitalize())

			# ❌ FAIL SOUND (invalid card)
			if AudioManager:
				AudioManager.play_sfx(AudioManager.scanner_sound_path, -10.0, 0.7) # quieter and lower pitch

func _on_interact():
	if GameManager.has_card(required_card_type, required_cards):
		GameManager.validate_scan(required_card_type, required_cards)
		interaction_area.message(unlock_message % required_card_type.capitalize())
	else:
		interaction_area.message(no_card_message % required_card_type.capitalize())

		# ❌ FAIL SOUND (no card)
		if AudioManager:
			AudioManager.play_sfx(AudioManager.scanner_sound_path, -10.0, 0.7)

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if not is_scanned:
		InteractionManager.base_text = text_to_display
	else:
		InteractionManager.base_text = unlock_message
