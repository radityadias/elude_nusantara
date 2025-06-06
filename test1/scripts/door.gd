extends AnimatableBody2D

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	GameManager.scanner_validated.connect(_on_scanner_result)

func _on_scanner_result(value: bool):
	if value:
		unlock()

func unlock():
	animation.play("door open")
	collision.queue_free()
