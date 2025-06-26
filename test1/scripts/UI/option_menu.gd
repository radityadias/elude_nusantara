extends Control

@onready var anim_back = $AnimatedSprite2D

func _ready():
	anim_back.play("Background")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Main_menu.tscn")
