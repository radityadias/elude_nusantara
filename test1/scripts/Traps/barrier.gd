extends "res://scripts/Traps/damage_area.gd"

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var main_collision: CollisionShape2D = $MainCollision

@export var required_order: int = 1

func _ready() -> void:
	GameManager.lever_activated.connect(update_state)
	animated_sprite_2d.play("idle")
	main_collision.disabled = false

func update_state(value: bool, order: int) -> void:
	if value and order == required_order:
		animated_sprite_2d.play("off")
		main_collision.disabled = true
	else:
		if order == required_order:
			animated_sprite_2d.play("on")
			main_collision.disabled = false
