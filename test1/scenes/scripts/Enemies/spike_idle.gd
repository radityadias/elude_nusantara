extends Area2D

@onready var game_manager: Node = $"../../GameManager"

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		game_manager.player_damaged()
