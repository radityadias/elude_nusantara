extends Control

@onready var anim_back = $AnimatedSprite2D

func _ready():
	anim_back.play("Background")

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/MainMenu/level_select.tscn")

func _on_option_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/MainMenu/option_menu.tscn")

func _on_credit_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/MainMenu/credit.tscn")
