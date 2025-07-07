extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var lever_cooldown: Timer = $Timer

@export var order: int = 1

var is_inside_lever: bool = false
var is_lever_active: bool = false

func _ready() -> void:
	pass

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_inside_lever = true

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_inside_lever = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and is_inside_lever and not is_lever_active:
		animated_sprite_2d.play("on")
		lever_cooldown.start()
		GameManager.lever_activated.emit(true, order)
		is_lever_active = true

func _on_timer_timeout() -> void:
	animated_sprite_2d.play_backwards("on")
	is_lever_active = false
	GameManager.lever_activated.emit(false, order)
