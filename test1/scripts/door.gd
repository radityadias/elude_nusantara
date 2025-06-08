extends AnimatableBody2D

@onready var animation: AnimatedSprite2D = $AnimatedSprite2D
@onready var main_collision: CollisionShape2D = $MainCollision
@onready var interaction_area: InteractionArea = $InteractionArea
@onready var finish_collision: CollisionShape2D = $Finish/FinishCollision
@onready var timer: Timer = $Timer

func _ready() -> void:
	GameManager.scanner_validated.connect(_on_scanner_result)
	finish_collision.disabled = true

func _on_scanner_result(value: bool):
	if value:
		unlock()

func unlock():
	animation.play("door open")
	main_collision.queue_free()
	finish_collision.disabled = false

func _on_finish_body_entered(body: Node2D) -> void:
	timer.start()

func _on_timer_timeout() -> void:
	get_tree().reload_current_scene()
