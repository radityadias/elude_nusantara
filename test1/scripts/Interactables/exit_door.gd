extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var ray_cast_2d_2: RayCast2D = $RayCast2D2

var is_door_open: bool = false
var is_cooldown: bool = false

func _physics_process(delta: float) -> void:
	on_door_open()

func on_door_open() -> void:
	if (ray_cast_2d.is_colliding() or ray_cast_2d_2.is_colliding()) and not is_door_open:
		animated_sprite_2d.play("on")
		is_door_open = true
	
	if not (ray_cast_2d.is_colliding() or ray_cast_2d_2.is_colliding()) and is_door_open:
		animated_sprite_2d.play_backwards("on")
		is_door_open = false

func _on_finish_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameManager.game_finish()
	
