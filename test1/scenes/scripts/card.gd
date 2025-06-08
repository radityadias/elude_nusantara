extends Node2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameManager.add_card()
		queue_free()
