extends Control

@onready var anim_back = $AnimatedSprite2D

func _ready():
	anim_back.play("Background")
	if AudioManager:
		AudioManager.play_music(AudioManager.default_bgm_path, -5.0)
	else:
		push_error("Error: AudioManager not found!")

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/MainMenu/level_select.tscn")

func _on_option_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/MainMenu/option_menu.tscn")

func _on_credit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/MainMenu/credit.tscn")
