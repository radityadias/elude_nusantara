@tool
extends TextureButton

signal level_selected

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

@onready var label_node = $Label

func _ready():
	update_display()

func update_display():
	if label_node:
		label_node.text = str(level_num)
	
	disabled = locked
	label_node.visible = not locked

func _on_pressed() -> void:
	level_selected.emit(level_num)
