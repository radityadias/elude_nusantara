extends Control

@onready var anim_back = $AnimatedSprite2D
@onready var level_container = $Control/LevelContainer

var all_levels_data: Array[LevelData] = []
@export var level_count: int = 10
@export var base_path: String = "res://scripts/Levels/Data/Level Data/level_" # Base path to your level data files

func _ready():
	load_all_level_data()
	
	for i in range(all_levels_data.size()):
		print("Level ID: ", all_levels_data[i].level_id)
		print("Level Cleared: ", all_levels_data[i].level_cleared)
		print(" ")
	anim_back.play("Background")
	setup_level_box()

func load_all_level_data() -> void:
	all_levels_data.clear()
	for i in range(1, level_count + 1):
		var file_path = base_path + str(i) + "_data.tres"
		if ResourceLoader.exists(file_path):
			var loaded_resource = ResourceLoader.load(file_path)
			if loaded_resource is LevelData:
				all_levels_data.append(loaded_resource as LevelData)
				print("Loaded level data: ", file_path)
			else:
				push_warning("Resource at '%s' is not a LevelData type." % file_path)
	print("Finished loading %d level data files." % all_levels_data.size())

func setup_level_box():
	var level_buttons = level_container.get_children()
	for i in range(all_levels_data.size()):
		var button = level_buttons[i]
		
		if not button.has_method("update_display"):
			continue
			
		button.level_num = i + 1
		button.stars = all_levels_data[i].total_stars
		

		if button.level_num <= count_cleared_levels() + 1:
			button.locked = false
		else:
			button.locked = true

func count_cleared_levels() -> int:
	var cleared_levels: int = 0
	for i in range(all_levels_data.size()):
		if all_levels_data[i].level_cleared:
			cleared_levels += 1
		else:
			cleared_levels += 0
	
	return cleared_levels

func _on_play_pressed() -> void:
	pass # Replace with function body.

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/Main_menu.tscn")
