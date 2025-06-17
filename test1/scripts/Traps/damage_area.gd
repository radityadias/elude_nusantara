extends Area2D
class_name DamageArea

@onready var game_manager: Node = get_tree().get_first_node_in_group("game_manager")

@export var damage_interval: float = 0.2
var is_inside: bool = false
var is_player_died: bool = false
var damage_timer := 0.0

func _physics_process(delta: float) -> void:
	if is_inside:
		damage_timer -= delta
		if damage_timer <= 0.0 and not game_manager.player_is_dead:
			var player = get_tree().get_first_node_in_group("player")
			if player and not player.is_invincible:
				damage_timer = damage_interval
				game_manager.player_damaged()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not game_manager.player_is_dead:
		is_inside = true
		damage_timer = 0.0
		game_manager.player_damaged()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and not game_manager.player_is_dead:
		is_inside = false
