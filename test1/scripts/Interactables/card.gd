extends Node2D # Atau Area2D, jika Card adalah Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	if AudioManager == null:
		print("ERROR: AudioManager AutoLoad not found in Card script!")
		

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameManager.add_card()
		print("Card collected!") # Pesan debugging
		if AudioManager: # Pastikan AudioManager tidak null
			AudioManager.play_sfx(AudioManager.card_collect_sound_path, -5.0, randf_range(0.9, 1.1))
		else:
			print("ERROR: AudioManager not found when trying to play card collect sound!")
		
		queue_free() # Kartu dihapus dari scene setelah diambil
