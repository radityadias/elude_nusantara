extends "res://scripts/Traps/damage_area.gd"

@onready var ray_cast_right: RayCast2D = $RayCastRight
@onready var ray_cast_left: RayCast2D = $RayCastLeft

@export var SPEED: float = 60
var direction: float = 1

func _process(delta: float) -> void:
	if ray_cast_right.is_colliding():
		direction = -1
	if ray_cast_left.is_colliding():
		direction = 1
	
	update_direction(delta)

func update_direction(delta: float) -> void:
	position.x += direction * SPEED * delta
