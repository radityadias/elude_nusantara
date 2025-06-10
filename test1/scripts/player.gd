extends CharacterBody2D

# STATE
enum {
	IDLE, 
	RUN,
	JUMP,
	DOUBLE_JUMP,
	PUSH,
	INVINCIBLE
}

signal get_damaged

# PLAYER MECHANIC
@export var HEARTH : Array[Node]
@export var SPEED : float = 200
@export var ACCELERATION : float = 600
@export var FRICTION : float = 800
@export var JUMP_FORCE : float = -350
@export var PUSH_FORCE : float = 200
@export var KNOCKBACK_FORCE : Vector2 = Vector2(100, -100)

# NODES
@onready var character: AnimatedSprite2D = $Character
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var run_particle: AnimatedSprite2D = $"Run Particle"
@onready var dust = preload("res://scenes/players/jump_particle.tscn")
@onready var main_collision: CollisionShape2D = $MainCollision
@onready var push_block: RigidBody2D = $"../Interactable/Push Block"
@onready var game_manager: Node = %GameManager
@onready var invincibility_timer: Timer = $InvincibilityTimer

var JUMP_COUNT : int = 0
var right_offset := Vector2(-8, 0)
var left_offset := Vector2(8, 0)
var lives: int = 3
var default_offset := Vector2.ZERO
var state : int = IDLE
var last_offset := Vector2.INF
var knockback_timer : float = 0.0
const knockback_duration : float = 0.2
var is_invincible : bool = false

# PHYSICS
var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_grounded: bool = true
const COYOTE_TIME: float = 0.15
const JUMP_BUFFER_TIME: float = 0.15
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0

func _ready() -> void:
	invincibility_timer.timeout.connect(end_invincibility)

func _process(delta: float) -> void:
	update_timers(delta)

func _physics_process(delta: float) -> void:
	if knockback_timer > 0:
		knockback_timer -= delta
		move_and_slide() 
		return

	var direction = Input.get_axis("move_left", "move_right")

	apply_gravity(delta)
	handle_state(direction, delta)
	apply_dust()
	apply_animation(direction)
	
	move_and_slide()
	update_state(direction)

# STATE MACHINE ================================================================
func handle_state(direction: float, delta: float) -> void:
	match state:
		IDLE, RUN:
			apply_movement(direction, delta)
			try_jump()
			try_push()
		JUMP, DOUBLE_JUMP:
			apply_movement(direction, delta)
			try_double_jump()
		PUSH:
			apply_movement(direction, delta)
			handle_push(direction)

func update_state(direction: float) -> void:
	if is_on_floor() and state in [JUMP, DOUBLE_JUMP]:
		state = IDLE if abs(velocity.x) < 1.0 else RUN
		JUMP_COUNT = 0
	elif is_on_floor():
		if direction != 0 and state != PUSH:
			state = RUN
		elif direction == 0 and state != PUSH:
			state = IDLE

func apply_gravity(delta: float):
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		coyote_timer = COYOTE_TIME

# MOVEMENT =====================================================================
func apply_movement(direction: float, delta: float):
	if direction != 0: 
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta * 2)
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
		velocity.y = JUMP_FORCE
		state = DOUBLE_JUMP
		JUMP_COUNT += 1

# Simplified push-only logic
func try_push() -> void:
	if Input.is_action_just_pressed("interact"):
		for i in get_slide_collision_count():
			var c = get_slide_collision(i)
			if c.get_collider() is RigidBody2D:
				state = PUSH
				return

func handle_push(direction: float) -> void:
	if Input.is_action_pressed("interact"):
		for i in get_slide_collision_count():
			var c = get_slide_collision(i)
			var body = c.get_collider()
			if body is RigidBody2D:
				body.apply_central_impulse(-c.get_normal() * PUSH_FORCE)
	else:
		state = IDLE if abs(velocity.x) < 1.0 else RUN

func update_timers(delta: float):
	if coyote_timer > 0: coyote_timer -= delta
	if jump_buffer_timer > 0: jump_buffer_timer -= delta
	if Input.is_action_just_pressed("jump"): jump_buffer_timer = JUMP_BUFFER_TIME

# ANIMATION ====================================================================
func apply_animation(direction: float):
	if state != PUSH and direction != 0:
		character.flip_h = direction < 0
		run_particle.flip_h = direction < 0
		run_particle.position.x = abs(run_particle.position.x) * (-1 if direction > 0 else 1)
	
	var target_offset := default_offset
	if state == PUSH:
		target_offset = right_offset if !character.flip_h else left_offset
	if target_offset != last_offset:
		character.offset = target_offset
		last_offset = target_offset
	
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
		PUSH:
			character.play("Push")  
			animation_player.play("push")
			run_particle.stop()

func apply_dust():
	var instance = dust.instantiate()
	if is_grounded == false and is_on_floor() == true:
		instance.global_position = $Marker2D.global_position
		get_parent().add_child(instance)
	elif is_grounded and not is_on_floor():
		instance.global_position = $Marker2D.global_position
		get_parent().add_child(instance)
	is_grounded = is_on_floor()

func decrease_health():
	if state == INVINCIBLE:
		return
		
	lives -= 1
	apply_knockback()
	start_invincibility()
	
	for h in 3:
		if h < lives:
			HEARTH[h].show()
		else:
			HEARTH[h].hide()
			
	
	if lives == 0:
		invincibility_timer.start()
		invincibility_timer.timeout.connect(GameManager.game_restart)
		
func apply_knockback() -> void:
	var knockback_direction = character.flip_h if character else false
	if knockback_direction:
		velocity = Vector2(KNOCKBACK_FORCE.x, KNOCKBACK_FORCE.y)
	else:
		velocity = Vector2(-KNOCKBACK_FORCE.x, KNOCKBACK_FORCE.y)
	
	knockback_timer = knockback_duration

func start_invincibility() -> void:
	state = INVINCIBLE
	is_invincible = true
	invincibility_timer.start()
	character.modulate.a = 0.5

func end_invincibility() -> void:
	state = IDLE
	is_invincible = false
	character.modulate.a = 1.0
