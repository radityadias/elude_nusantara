extends CharacterBody2D

signal is_interact
signal is_push
signal push_state_changed(is_pushing: bool, direction: int)  # New signal for animations

var direction: int = 0
var can_push: bool = false
var is_pushing: bool = false
var push_speed: float = 1500.0
var player_ref: Node2D = null  # Reference to the player
var start_position : Vector2

func _ready() -> void:
	get_current_position()
	GameManager.box_reseted.connect(reset_position)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if can_push:
		handle_push()
	
	if is_pushing:
		velocity.x = direction * delta * push_speed 
		# Notify player to play push animation
		push_state_changed.emit(true, direction)
	else: 
		velocity.x = move_toward(velocity.x, 0, push_speed * delta)
		if can_push:  # Only send stop if player is still nearby
			push_state_changed.emit(false, direction)
	
	move_and_slide()

func _on_left_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		direction = 1  # Push right
		can_push = true
		player_ref = body  # Store player reference

func _on_left_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		direction = 0
		can_push = false
		is_pushing = false
		push_state_changed.emit(false, 0)  # Ensure animation stops
		player_ref = null

func _on_right_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		direction = -1  # Push left
		can_push = true
		player_ref = body  # Store player reference

func _on_right_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		direction = 0
		can_push = false
		is_pushing = false
		push_state_changed.emit(false, 0)  # Ensure animation stops
		player_ref = null

func handle_push() -> void:
	if Input.is_action_pressed("interact"):
		# Check correct movement key based on push direction
		if (direction == 1 and Input.is_action_pressed("move_right")):
			is_pushing = true
			# Flip player to face push direction if needed
			if player_ref and player_ref.has_method("set_facing_direction"):
				player_ref.set_facing_direction(false)  # Face right
				
		elif (direction == -1 and Input.is_action_pressed("move_left")):
			is_pushing = true
			# Flip player to face push direction if needed
			if player_ref and player_ref.has_method("set_facing_direction"):
				player_ref.set_facing_direction(true)  # Face left
		else:
			is_pushing = false
	else:
		is_pushing = false

func get_current_position() -> void:
	start_position = position

func reset_position() -> void:
	position = start_position
