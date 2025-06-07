extends Area2D

@onready var game_manager: Node = $"../../GameManager"

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		print("touched enemy")
		game_manager.decrease_health()
