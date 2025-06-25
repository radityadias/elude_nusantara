extends Control

signal closed

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var level: Label = $CenterContainer/Panel/Level

@export var STARS: Array[Node]

var base_path: String = "res://scenes/Levels/level_"

var current_level_data: LevelData = null
var level_id: int
var stars: int

func _ready() -> void:
	animation_player.play("on")
	if current_level_data:
		update_display_from_level_data()

func set_level_data(level_data_resource: LevelData) -> void:
	current_level_data = level_data_resource
	
	print("set_level_data called. Is 'level' valid? ", is_instance_valid(level)) # <-- Add this line

	if current_level_data:
		level_id = current_level_data.level_id 
		
		# Set the stars from the LevelData
		stars = current_level_data.total_stars
		
		# Update the display immediately
		update_display_from_level_data()
	else:
		push_warning("set_level_data received a null LevelData resource.")


func update_display_from_level_data() -> void:
	if current_level_data:
		# Update the level label
		update_level_label(current_level_data.level_id)
		
		# Update the star display
		update_star_display()
	else:
		# Handle the case where current_level_data is null, e.g., clear display
		level.text = "Level --"
		stars = 0
		update_star_display()


func _on_close_button_pressed():
	# Before queue_free, make sure the animation finishes playing "off" if you have one.
	# For simplicity, if you want to close immediately, this is fine.
	queue_free()
	closed.emit() # Emit the signal when the UI is closed

# This function might be redundant if _on_close_button_pressed handles closing
func _on_texture_button_pressed() -> void:
	queue_free() # This seems to be a generic close button. Consider combining with _on_close_button_pressed.
	closed.emit() # Make sure to emit closed here as well if this is another way to close.

func _on_play_pressed() -> void: # Removed 'value: int' parameter from signal receiver
	if current_level_data:
		var file_path = base_path + str(current_level_data.level_id) + ".tscn"
		get_tree().change_scene_to_file(file_path)
	else:
		push_warning("Cannot play level: current_level_data is null.")

func update_star_display() -> void:
	for i in STARS.size():
		if STARS[i] is TextureRect:
			var star_texture_rect = STARS[i] as TextureRect
			if i < stars:
				star_texture_rect.texture = load("res://assets/Sprites/GUI/Active_Star.png")
			else:
				star_texture_rect.texture = load("res://assets/Sprites/GUI/Unactive_Star.png")
		else:
			push_warning("STARS array contains non-TextureRect nodes at index %d. Skipping." % i)

func update_level_label(value: int) -> void:
	print("Level label: ", value)
	level.text = "Level " + str(value)
