@tool
extends TextureButton

signal level_selected

@export var STARS: Array[Node]

@export var level_num: int = 1:
	set(value):
		level_num = value
		if is_inside_tree():
			update_display()

@export var locked: bool = true:
	set(value):
		locked = value
		if is_inside_tree():
			update_display()
			
@export var stars: int = 0:
	set(value):
		stars = value
		if is_inside_tree():
			update_star_display()

@onready var label_node = $Label

var base_path: String = "res://scenes/Levels/level_"
var select_ui: PackedScene = load("res://scenes/UI/level_select.tscn")

func _ready():
	update_display()
	update_star_display()

func update_display():
	if label_node:
		label_node.text = str(level_num)
	
	disabled = locked
	label_node.visible = not locked

func update_star_display() -> void:
	for i in STARS.size():
		if STARS[i] is TextureRect: # Always check the type
			var star_texture_rect = STARS[i] as TextureRect
			if i < stars:
				star_texture_rect.texture = load("res://assets/Sprites/GUI/Active_Star.png")
			else:
				star_texture_rect.texture = load("res://assets/Sprites/GUI/Unactive_Star.png")
		else:
			push_warning("STARS array contains non-TextureRect nodes at index %d. Skipping." % i)

func _on_pressed() -> void:
	var select_instance = select_ui.instantiate()
	get_tree().root.add_child(select_instance)
	select_instance.show_level_detail_ui()
	print("Level ", level_num, " Pressed")
