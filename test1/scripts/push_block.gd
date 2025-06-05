extends CharacterBody2D

var push : bool = false
var direction : int = 0
var gravity = ProjectSettings.get("physics/2d/default_gravity")

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if push:
		velocity.x = direction * 2000 
	else:
		velocity.x = 0
	
	move_and_slide()

func _on_left_body_entered(body: Node2D) -> void:
	print(body.name, " ENTERED LEFT!")  # Always prints
	if body.is_in_group("player"):
		direction = 1
		push = true

func _on_right_body_entered(body: Node2D) -> void:
	print(body.name, " ENTERED RIGHT!")  # Always prints
	if body.is_in_group("player"):
		direction = -1
		push = true

func _on_left_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		await get_tree().process_frame
		if not $left.has_overlapping_bodies():
			direction = 0
			push = false

func _on_right_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		await get_tree().process_frame
		if not $left.has_overlapping_bodies():
			direction = 0
			push = false
