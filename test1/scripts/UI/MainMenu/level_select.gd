extends Control

@onready var level_container = $CenterContainer/VBoxContainer/LevelContainer

@export var level_count: int = 5
@export var base_path: String = "res://scripts/Levels/Data/LevelData/level_"
@export var detail_ui: PackedScene
@export var level_button_ui: PackedScene

var all_levels_data: Array[LevelData] = []
var current_active_ui: Control
var current_pressed_button: TextureButton = null
var is_ui_opened: bool = false

func _ready():
	load_all_level_data()
	setup_level_box()

func load_all_level_data() -> void:
	all_levels_data.clear()
	
	for i in range(1, level_count + 1):
		var file_path: String
		
		if Engine.is_editor_hint():
			file_path = base_path + str(i) + "_data.tres"
		else:
			file_path = "user://%d.tres" % i

		var level_data: LevelData = null
		
		if ResourceLoader.exists(file_path):
			var loaded_resource = ResourceLoader.load(file_path)
			if loaded_resource is LevelData:
				level_data = loaded_resource as LevelData
				print("Loaded level %d from save." % i)
			else:
				push_warning("Resource at '%s' is not a LevelData type." % file_path)
		
		if level_data == null:
			# Fallback: create a new default LevelData
			level_data = LevelData.new()
			level_data.level_id = i
			print("Created default data for level %d" % i)

		all_levels_data.append(level_data)
		print_data()

func setup_level_box():
	var level_buttons = level_container.get_children()
	for i in range(all_levels_data.size()):
		var button = level_buttons[i]
		
		if not button.has_method("update_display"):
			continue
		
		if button is TextureButton: 
			button.level_selected.connect(on_level_button_selected)
		
		button.level_num = i + 1
		button.stars = all_levels_data[i].total_stars

		if button.level_num <= count_cleared_levels() + 1:
			button.locked = false
		else:
			button.locked = true

func on_level_button_selected(level_num_selected: int) -> void:	
	if is_ui_opened:
		print("UI already opened, ignoring new request.")
		return
	
	# Find the actual button instance that was pressed
	for button_node in level_container.get_children():
		if button_node is TextureButton and button_node.level_num == level_num_selected:
			current_pressed_button = button_node as TextureButton
			break

	# Only proceed if a button was actually found
	if current_pressed_button:
		show_level_detail_ui(level_num_selected) # Pass the level_num to the show function

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
	get_tree().change_scene_to_file("res://scenes/UI/MainMenu/main_menu.tscn")

func show_level_detail_ui(level_id: int) -> void:
	if is_ui_opened:
		print("UI already opened, ignoring new request.")
		return

	if current_active_ui != null and is_instance_valid(current_active_ui):
		current_active_ui.queue_free()
		current_active_ui = null 

	var detail_instance = detail_ui.instantiate() # Instantiate the scene

	var ui_root_layer = get_tree().get_first_node_in_group("detail_canvas")
	if ui_root_layer:
		# 1. ADD THE INSTANCE TO THE SCENE TREE FIRST.
		#    This ensures that all @onready variables in detail_instance (and its children)
		#    are assigned, and _ready() methods are called.
		ui_root_layer.add_child(detail_instance)
		current_active_ui = detail_instance
		is_ui_opened = true
		
		# 2. NOW IT'S SAFE TO CALL METHODS THAT RELY ON @onready VARIABLES.
		if detail_instance.has_method("set_level_data"):
			var selected_level_data = null
			for data in all_levels_data:
				if data.level_id == level_id:
					selected_level_data = data
					break
			if selected_level_data:
				# Cast to the specific script type for type safety and autocompletion if desired
				(detail_instance as Control).set_level_data(selected_level_data) 
				# I used 'Control' here, but replace it with the actual class name of your detail_ui script
				# if you defined it with 'class_name YourDetailUIScriptName'
			else:
				push_warning("LevelData not found for level_id: %d" % level_id)
		else:
			push_warning("Detail UI instance does not have 'set_level_data' method.")


		# 3. Connect signals after it's in the tree and set up
		if detail_instance.has_signal("closed"):
			detail_instance.closed.connect(on_detail_ui_closed)
		else:
			push_warning("Detail UI instance does not have 'closed' signal.")
	else:
		print("No node found in 'detail_canvas' group ")
		push_error("No node found in 'detail_canvas' group")
		# If UI root not found, re-enable the button as the UI won't open
		if current_pressed_button:
			current_pressed_button.disabled = false

func on_detail_ui_closed() -> void:
	is_ui_opened = false
	if current_active_ui and is_instance_valid(current_active_ui):
		current_active_ui.queue_free()
		current_active_ui = null
	
	# Re-enable the button that was pressed
	if current_pressed_button:
		current_pressed_button.disabled = false
		current_pressed_button = null # Clear the reference

func print_data() -> void:
	for data in all_levels_data:
		print("Level ID: ", data.level_id)
		print("Cleared: ", data.level_cleared)
