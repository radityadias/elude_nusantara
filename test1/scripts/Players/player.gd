extends CharacterBody2D

# ===== EXPORT VARIABLES =====
@export var HEARTH : Array[Node]
@export var SPEED : float = 200
@export var ACCELERATION : float = 600
@export var FRICTION : float = 800
@export var JUMP_FORCE : float = -350
@export var PUSH_FORCE : float = 200
@export var KNOCKBACK_FORCE : Vector2 = Vector2(100, -100)

# ===== CONSTANTS =====
const COYOTE_TIME: float = 0.15
const JUMP_BUFFER_TIME: float = 0.15
const KNOCKBACK_DURATION: float = 0.2

# ===== STATE MANAGEMENT =====
enum State {
	IDLE, 
	RUN,
	JUMP,
	DOUBLE_JUMP,
	PUSH,
	INVINCIBLE,
	JUMP_PAD,
	DEAD,
}
var state : State = State.IDLE
var JUMP_PAD_FORCE : float = -650
var JUMP_COUNT : int = 0

# ===== HEALTH SYSTEM =====
var lives: int = 3
var is_invincible : bool = false

# ===== PHYSICS VARIABLES =====
var GRAVITY = ProjectSettings.get_setting("physics/2d/default_gravity")
var is_grounded: bool = true
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var knockback_timer : float = 0.0

# ===== NODE REFERENCES =====
@onready var character: AnimatedSprite2D = $Character
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var run_particle: AnimatedSprite2D = $"Run Particle"
@onready var dust = preload("res://scenes/players/jump_particle.tscn")
@onready var invincibility_timer: Timer = $InvincibilityTimer
@onready var marker_2d: Marker2D = $Marker2D

# ===== ANIMATION OFFSETS =====
var right_offset := Vector2(-8, 0)
var left_offset := Vector2(8, 0)
var default_offset := Vector2.ZERO
var last_offset := Vector2.INF

# ===== INITIALIZATION =====
func _ready() -> void:
	connect_signals()
	setup_pushable_connections()

func connect_signals() -> void:
	GameManager.jumppad_used.connect(try_jump_pad)
	invincibility_timer.timeout.connect(end_invincibility)

func setup_pushable_connections() -> void:
	for block in get_tree().get_nodes_in_group("pushable"):
		if block.has_signal("push_state_changed"):
			block.push_state_changed.connect(_on_push_state_changed)

# ===== PROCESS FUNCTIONS =====
func _process(delta: float) -> void:
	update_timers(delta)

func _physics_process(delta: float) -> void:
	print("Current State: ", state)
	if state == State.DEAD:
		return 
	
	handle_knockback_state(delta)
	if is_knockback_active(): 
		move_and_slide()
		return
	
	var direction := get_input_direction()
	update_movement(direction, delta)
	update_animations(direction)
	move_and_slide()
	update_state_based_on_movement(direction)

# ===== MOVEMENT SYSTEM =====
func handle_knockback_state(delta: float) -> void:
	if knockback_timer > 0:
		knockback_timer -= delta

func is_knockback_active() -> bool:
	return knockback_timer > 0

func get_input_direction() -> float:
	return Input.get_axis("move_left", "move_right")

func update_movement(direction: float, delta: float) -> void:
	apply_gravity(delta)
	handle_state_movement(direction, delta)
	handle_dust_effects()

func apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		coyote_timer = COYOTE_TIME

func handle_state_movement(direction: float, delta: float) -> void:
	match state:
		State.IDLE, State.RUN, State.JUMP, State.DOUBLE_JUMP, State.PUSH:
			apply_horizontal_movement(direction, delta)
		State.JUMP_PAD:
			apply_jumppad_movement(direction, delta)

	if state in [State.IDLE, State.RUN]:
		try_jump()
	elif state in [State.JUMP, State.DOUBLE_JUMP]:
		try_double_jump()

func apply_horizontal_movement(direction: float, delta: float) -> void:
	if direction != 0: 
		velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta * 2)
	else: 
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta * 2)

func apply_jumppad_movement(direction: float, delta: float) -> void:
	if direction != 0: 
		velocity.x = move_toward(velocity.x, direction * SPEED, 400 * delta)
	else: 
		velocity.x = move_toward(velocity.x, 0, FRICTION * delta * 2)

# ===== JUMP SYSTEM =====
func try_jump() -> void:
	if can_jump():
		execute_jump(State.JUMP)

func try_double_jump() -> void:
	if Input.is_action_just_pressed("jump") and JUMP_COUNT < 2:
		execute_jump(State.DOUBLE_JUMP)

func can_jump() -> bool:
	return (jump_buffer_timer > 0 or coyote_timer > 0) and Input.is_action_just_pressed("jump")

func execute_jump(new_state: State) -> void:
	velocity.y = JUMP_FORCE
	state = new_state
	JUMP_COUNT += 1
	reset_jump_timers()

func reset_jump_timers() -> void:
	jump_buffer_timer = 0
	coyote_timer = 0

func update_timers(delta: float) -> void:
	if coyote_timer > 0: coyote_timer -= delta
	if jump_buffer_timer > 0: jump_buffer_timer -= delta
	if Input.is_action_just_pressed("jump"): jump_buffer_timer = JUMP_BUFFER_TIME

# ===== STATE MANAGEMENT =====
func update_state_based_on_movement(direction: float) -> void:
	if is_on_floor():
		JUMP_COUNT = 0
		if state in [State.JUMP, State.DOUBLE_JUMP]:
			state = State.RUN if abs(velocity.x) >= 1.0 else State.IDLE
		elif state != State.PUSH:
			state = State.RUN if direction != 0 else State.IDLE

# ===== PUSH SYSTEM =====
func _on_push_state_changed(is_pushing: bool, direction: int) -> void:
	if is_pushing:
		state = State.PUSH
		character.flip_h = direction < 0
	elif state == State.PUSH:
		state = State.IDLE

# ===== ANIMATION SYSTEM =====
func update_animations(direction: float) -> void:
	update_character_direction(direction)
	update_animation_state()
	update_sprite_offset()

func update_character_direction(direction: float) -> void:
	if state != State.PUSH and direction != 0:
		character.flip_h = direction < 0
		run_particle.flip_h = direction < 0
		run_particle.position.x = abs(run_particle.position.x) * (-1 if direction > 0 else 1)

func update_animation_state() -> void:
	if state == State.DEAD:
		return
	
	match state:
		State.IDLE: 
			play_animation("Idle", "idle")
			run_particle.stop()
		State.RUN: 
			play_animation("Run", "run")
			run_particle.play("running_dust")
		State.JUMP, State.DOUBLE_JUMP, State.JUMP_PAD:
			if character.animation != "Jump":
				play_animation("Jump", "jump")
			run_particle.stop()
		State.PUSH:
			play_animation("Push", "push")
			run_particle.stop()

func play_animation(anim_name: String, anim_player_anim: String) -> void:
	character.play(anim_name)
	animation_player.play(anim_player_anim)

func update_sprite_offset() -> void:
	var target_offset := default_offset
	if state == State.PUSH:
		target_offset = right_offset if !character.flip_h else left_offset
	if target_offset != last_offset:
		character.offset = target_offset
		last_offset = target_offset

func handle_dust_effects() -> void:
	if should_spawn_dust():
		spawn_dust()
	is_grounded = is_on_floor()

func should_spawn_dust() -> bool:
	return is_grounded != is_on_floor()

func spawn_dust() -> void:
	var instance = dust.instantiate()
	instance.global_position = marker_2d.global_position
	get_parent().add_child(instance)

# ===== COMBAT SYSTEM =====
func decrease_health() -> void:	
	if state == State.INVINCIBLE or state == State.DEAD:
		return
	
	lives -= 1
	update_hearth_display()

	if lives == 0:
		handle_dead()
		return
		
	start_invincibility()
	apply_knockback()

func apply_knockback() -> void:
	velocity = Vector2(KNOCKBACK_FORCE.x if character.flip_h else -KNOCKBACK_FORCE.x, KNOCKBACK_FORCE.y)
	knockback_timer = KNOCKBACK_DURATION

func update_hearth_display() -> void:
	for i in HEARTH.size():
		HEARTH[i].visible = i < lives

# ===== INVINCIBILITY SYSTEM =====
func start_invincibility() -> void:
	state = State.INVINCIBLE
	is_invincible = true
	invincibility_timer.start()
	character.modulate.a = 0.5

func end_invincibility() -> void:
	state = State.IDLE
	is_invincible = false
	character.modulate.a = 1.0

# ===== PLAYER DEATH =====
func handle_dead() -> void:
	state = State.DEAD
	GameManager.player_dead()

# ===== SPECIAL ABILITIES =====
func try_jump_pad() -> void:
	velocity.y = JUMP_PAD_FORCE
	state = State.JUMP_PAD
