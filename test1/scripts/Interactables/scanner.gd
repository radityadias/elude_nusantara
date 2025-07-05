# File: ScannerLogic.gd (Skrip utama untuk objek Scanner Anda)
extends Area2D # Ini adalah base class dari node root Scanner Anda

@onready var interaction_area_child: InteractionArea = $InteractionArea # Variabel untuk child InteractionArea

@export var required_cards: int = 1
@export var required_card_type: String = "default"

const text_to_display : String = "[E] to interact"
const unlock_message : String = "%s door Unlocked!"
const no_card_message: String = "You need a %s card"
var is_scanned : bool = false

func _ready() -> void:
	if AudioManager == null:
		print("ERROR: AudioManager AutoLoad not found in ScannerLogic.gd!")

func _on_game_manager_scanner_validated(scanned_card_type: String, success: bool):
	if scanned_card_type == required_card_type:
		if success:
			is_scanned = true
			interaction_area.message(unlock_message)
			GameManager.consume_card(required_card_type, required_cards)
		else:
			is_scanned = false
			interaction_area.message(no_card_message % required_card_type.capitalize())
func _on_interact():
	if GameManager.has_card(required_card_type, required_cards):
		GameManager.validate_scan(required_card_type, required_cards)
		interaction_area.message(unlock_message % required_card_type.capitalize())
	else:
		interaction_area.message(no_card_message % required_card_type.capitalize())

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if not is_scanned:
		InteractionManager.base_text = text_to_display
	else:
		InteractionManager.base_text = unlock_message

func _on_interact_scanner(): # Fungsi ini dipanggil ketika player menekan 'E'
	print("DEBUG: ScannerLogic: _on_interact_scanner (interaction) triggered!")
	
	if GameManager.cards_collected == 0:
		interaction_area_child.message("You need a keycard")
		# --- AUDIO: Suara scanner GAGAL (ketika tidak punya kartu) ---
		if AudioManager:
			# Mainkan suara yang menunjukkan kegagalan, mungkin pitch lebih rendah atau volume lebih pelan
			AudioManager.play_sfx(AudioManager.scanner_sound_path, -10.0, 0.7) # Contoh: -10 dB, pitch 0.8
		print("DEBUG: ScannerLogic: Player has no card. Played scanner FAIL sound.")
	elif GameManager.cards_collected >= required_cards:
		GameManager.validate_scan()
		is_scanned = true
		interaction_area_child.message(unlock_message)
		# --- AUDIO: Suara scanner SUKSES (ketika punya kartu) ---
		if AudioManager:
			# Mainkan suara yang menunjukkan keberhasilan, mungkin pitch normal atau lebih tinggi
			AudioManager.play_sfx(AudioManager.scanner_sound_path, -3.0, 1.1) # Contoh: -3 dB, pitch 1.0 (normal)
		print("DEBUG: ScannerLogic: Player has card. Played scanner SUCCESS sound.")

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if not is_scanned:
			InteractionManager.base_text = text_to_display
		else:
			InteractionManager.base_text = unlock_message
		print("DEBUG: ScannerLogic: _on_interaction_area_body_entered called.")
