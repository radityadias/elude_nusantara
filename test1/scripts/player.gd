extends CharacterBody2D

enum {
	IDLE, 
	RUN,
	JUMP,
	DOUBLE_JUMP,
	PUSH,
	PULL
}

# PLAYER MECHANIC
@export var SPEED : float = 250
@export var ACCELERATION : float = 600
@export var FRICTION : float = 800
@export var JUMP_FORCE : float = -350
@export var PUSH_FORCE : float = 200
var JUMP_COUNT : int = 0
var state : int = IDLE

# NODES
@onready var character: AnimatedSprite2D = $Character
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var run_particle: AnimatedSprite2D = $"Run Particle"
@onready var dust = preload("res://scenes/players/jump_particle.tscn")

# Physics
var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_grounded: bool = true

const COYOTE_TIME: float = 0.15
const JUMP_BUFFER_TIME: float = 0.15

var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

func _process(delta: float) -> void:
	update_timers(delta)

func _physics_process(delta: float) -> void:
	var direction = Input.get_axis("move_left", "move_right") # Get input direction (-1, 0, or 1)
	
	apply_gravity(delta)
	handle_state(direction, delta)
	apply_dust()
	apply_animation(direction)

	move_and_slide()
	update_state(direction)

func handle_state(direction: float, delta: float) -> void:
	match state:
		IDLE, RUN:
			apply_movement(direction, delta)
			try_jump()
			try_push_pull()
		JUMP, DOUBLE_JUMP:
			apply_movement(direction, delta)
			try_double_jump()
		PUSH, PULL:
			handle_push_pull(direction)

func update_state(direction: float) -> void:
	if is_on_floor() and state in [JUMP, DOUBLE_JUMP]:
		state = IDLE if abs(velocity.x) < 1.0 else RUN
		JUMP_COUNT = 0
	elif is_on_floor():
		if direction != 0 and state not in [PUSH, PULL]:
			state = RUN
		elif direction == 0 and state not in [PUSH, PULL]:
			state = IDLE

func apply_gravity(delta: float):
	# Apply gravity and handle coyote time
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		coyote_timer = COYOTE_TIME  # Reset coyote timer when on ground

func apply_movement(direction: float, delta: float):
	# Horizontal movement
	if direction != 0: 
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta * 2)
		character.flip_h = direction < 0
		run_particle.flip_h = direction < 0
		run_particle.position.x = abs(run_particle.position.x) * (-1 if direction > 0 else 1)
	else: 
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta * 2)

func try_jump():
	if (jump_buffer_timer > 0 or coyote_timer > 0) and Input.is_action_just_pressed("jump"):
		velocity.y = JUMP_FORCE
		state = JUMP
		JUMP_COUNT += 1
		jump_buffer_timer = 0
		coyote_timer = 0

func try_double_jump() -> void:
	if (Input.is_action_just_pressed("jump") and JUMP_COUNT < 2):
		velocity.y =JUMP_FORCE
		state = DOUBLE_JUMP
		JUMP_COUNT += 1

func try_push_pull() -> void:
	if Input.is_action_just_pressed("interact"):
		for i in get_slide_collision_count():
			var c = get_slide_collision(i)
			
			if c.get_collider() is RigidBody2D:
				state = PUSH if velocity.x != 0 else PULL
				return

func handle_push_pull(direction: float) -> void:
	if Input.is_action_pressed("interact"):
		for i in get_slide_collision_count():
			var c = get_slide_collision(i)
			
			if c.get_collider() is RigidBody2D:
				c.get_collider().apply_central_impulse(-c.get_normal() * PUSH_FORCE)
	else:
		state = IDLE if abs(velocity.x) < 1.0 else RUN

func apply_animation(direction: float):
	match state:
		IDLE: 
			character.play("Idle")
			animation_player.play("idle")
			run_particle.stop()
		RUN: 
			character.play("Run")
			run_particle.play("running_dust")
			animation_player.play("run")
		JUMP, DOUBLE_JUMP:
			if character.animation != "Jump":
				character.play("Jump")
			animation_player.play("jump")
			run_particle.stop()
		PUSH, PULL:
			character.play("Push")  # You'll need to create this animation
			run_particle.stop()

func apply_dust():
	var instance = dust.instantiate()
	
	# Landing Dust Effect
	if is_grounded == false and is_on_floor() == true:
		instance.global_position = $Marker2D.global_position
		get_parent().add_child(instance)
	
	# Jump Dust Effect
	if is_grounded and not is_on_floor():
		instance.global_position = $Marker2D.global_position
		get_parent().add_child(instance)
	
	is_grounded = is_on_floor()

func update_timers(delta: float):
	# Reduce timers
	if coyote_timer > 0: coyote_timer -= delta
	if jump_buffer_timer > 0: jump_buffer_timer -= delta

	# Store jump input in buffer
	if Input.is_action_just_pressed("jump"):jump_buffer_timer = JUMP_BUFFER_TIME
