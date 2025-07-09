extends AnimatableBody2D

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var main_collision: CollisionShape2D = $MainCollision

@export var required_card_type: String = "default"

var is_unlocked : bool = false
var is_game_finished: bool = false
var is_exit_unlocked: bool = false

func _ready() -> void:
	GameManager.scanner_validated.connect(_on_scanner_result)

func _on_scanner_result(scanned_card_type: String, value: bool):
	if scanned_card_type == required_card_type and value:
		unlock()

func unlock():
	if not is_unlocked:
		is_unlocked = true
		animation.play("door open")
		main_collision.queue_free()
		
		# --- AUDIO: Mainkan suara pintu terbuka ---
		if AudioManager: # Pastikan AudioManager tidak null sebelum memanggilnya
			AudioManager.play_sfx(AudioManager.door_open_sound_path, 0.0, 2.0) # Contoh volume -8.0 dB
		else:
			push_error("ERROR: AudioManager not found when trying to play door sound!")
