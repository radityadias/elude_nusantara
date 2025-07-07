extends Node2D # Atau Area2D, jika Card adalah Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

@export var card_type: String = "default"

func _ready() -> void:
	if AudioManager == null:
		push_error("ERROR: AudioManager AutoLoad not found in Card script!")
		

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameManager.add_card(card_type)
		if AudioManager: # Pastikan AudioManager tidak null
			AudioManager.play_sfx(AudioManager.card_collect_sound_path, -5.0)
		else:
			push_error("ERROR: AudioManager not found when trying to play card collect sound!")
		
		queue_free() # Kartu dihapus dari scene setelah diambil
