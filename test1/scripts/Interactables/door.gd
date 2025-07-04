extends AnimatableBody2D

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var main_collision: CollisionShape2D = $MainCollision
@onready var interaction_area: InteractionArea = $InteractionArea
@onready var finish_collision: CollisionShape2D = $Finish/FinishCollision
@onready var timer: Timer = $Timer

var is_unlocked : bool = false

func _ready() -> void:
	GameManager.scanner_validated.connect(_on_scanner_result)
	finish_collision.disabled = true
	if AudioManager == null:
		print("ERROR: AudioManager AutoLoad not found in Door script!")

func _on_scanner_result(value: bool):
	if value:
		unlock()

func unlock():
	if not is_unlocked:
		is_unlocked = true
		animation.play("door open")
		main_collision.queue_free()
		finish_collision.disabled = false
		print("Pintu terbuka!") # Pesan debugging

		# --- AUDIO: Mainkan suara pintu terbuka ---
		if AudioManager: # Pastikan AudioManager tidak null sebelum memanggilnya
			AudioManager.play_sfx(AudioManager.door_open_sound_path, 0.0, 2.0) # Contoh volume -8.0 dB
		else:
			print("ERROR: AudioManager not found when trying to play door sound!")

func _on_finish_body_entered(body: Node2D) -> void:
	GameManager.game_finish()
