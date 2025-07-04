extends Control

@onready var anim_back = $AnimatedSprite2D

func _ready():
	anim_back.play("Background")
	if AudioManager:
		# 1. Memutar musik latar. Setel volume awal INSTANCE music_player ke 0.0 dB (volume asli file)
		# atau sedikit lebih rendah, misal -5.0 dB. JANGAN -80 dB.
		AudioManager.play_music(AudioManager.default_bgm_path, -5.0) # <-- UBAH NILAI INI. Contoh: -5.0 dB

		# 2. Kemudian, atur volume keseluruhan BUS "Music" ke level yang Anda inginkan (0.0 hingga 1.0)
		# Misalnya, 0.1 untuk 10%, 0.5 untuk 50%.
		AudioManager.set_music_volume(0.5) # <-- UBAH NILAI INI. Contoh: 0.5 (50% volume)
	else:
		print("Error: AudioManager not found!")

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/level_select.tscn")

func _on_option_pressed() -> void:
	get_tree().change_scene_to_file("res://Option_menu.tscn")

func _on_credit_pressed() -> void:
	get_tree().change_scene_to_file("res://Credit.tscn")
