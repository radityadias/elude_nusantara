extends Control

@onready var anim_back = $AnimatedSprite2D
@onready var level_container = $Control/LevelContainer

func _ready():
	anim_back.play("Background")
	setup_level_box()
	
func setup_level_box():
	var level_buttons = level_container.get_children()
	
	for i in range(level_buttons.size()):
		var button = level_buttons[i]
		
		if not button.has_method("update_display"):
			continue
			
		button.level_num = i + 1
		
		if button.level_num <= 1:
			button.locked = false
		else:
			button.locked = true


func _on_play_pressed() -> void:
	pass # Replace with function body.


func _on_back_button_pressed() -> void:
	pass # Replace with function body.
