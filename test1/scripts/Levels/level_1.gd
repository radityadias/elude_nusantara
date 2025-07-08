extends Node2D

func _on_finish_area_body_entered(body: Node2D) -> void:
	GameManager.game_finish()
