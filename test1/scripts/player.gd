extends CharacterBody2D

# PLAYER MECHANIC
@export var SPEED : float = 250
@export var ACCELERATION : float = 600
@export var FRICTION : float = 800
@export var JUMP_FORCE : float = -350
@export var PUSH_FORCE : float = 200
var JUMP_COUNT : int = 0

# NODES
@onready var character: AnimatedSprite2D = $Character
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var run_particle: AnimatedSprite2D = $"Run Particle"
@onready var dust = preload("res://scenes/players/jump_particle.tscn")

# CUSTOM VARIABLES
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
	apply_movement(direction, delta)
	apply_jump_logic()
	push_pull_logic()
	apply_dust()
	apply_animation(direction)

	move_and_slide()

func apply_gravity(delta: float):
	# Apply gravity and handle coyote time
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		coyote_timer = COYOTE_TIME  # Reset coyote timer when on ground
		JUMP_COUNT = 0

func apply_movement(direction: float, delta: float):
	# Horizontal movement
	if direction != 0: 
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta * 2)
	else: 
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta * 2)

func apply_jump_logic():
	# Check jump conditions
	
	# Single Jump
	if (jump_buffer_timer > 0 or coyote_timer > 0) and JUMP_COUNT == 0 and Input.is_action_just_pressed("jump") :
		apply_jump()
		JUMP_COUNT += 1
		print("JUMP COUNT : ", JUMP_COUNT)
	
	# Double Jump
	elif Input.is_action_just_pressed("jump") and not is_on_floor() and JUMP_COUNT < 2:
		apply_jump()
		JUMP_COUNT += 1
		print("JUMP COUNT : ", JUMP_COUNT)

func apply_jump() -> void:
	velocity.y = JUMP_FORCE
	jump_buffer_timer = 0  # Clear jump buffer
	coyote_timer = 0  # Disable coyote time after jumping

func apply_animation(direction: float):
	# Flip sprites based on movement direction
	if direction != 0:
		character.flip_h = direction < 0
		run_particle.flip_h = direction < 0
		run_particle.position.x = abs(run_particle.position.x) * (-1 if direction > 0 else 1)

	if is_on_floor():
		if direction != 0: # RUN
			character.play("Run")
			run_particle.play("running_dust")
			animation_player.play("run")
		else: # IDLE
			character.play("Idle")
			animation_player.play("idle")
			run_particle.stop()
	else: # JUMP
		if character.animation != "Jump":
			character.play("Jump")
		animation_player.play("jump")
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
	if coyote_timer > 0:
		coyote_timer -= delta
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta

	# Store jump input in buffer
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = JUMP_BUFFER_TIME

func push_pull_logic() -> void:
	for i in get_slide_collision_count():
		var c = get_slide_collision(i)
		if c.get_collider() is RigidBody2D and Input.is_action_pressed("interact"):
			c.get_collider().apply_central_impulse(-c.get_normal() * PUSH_FORCE)
