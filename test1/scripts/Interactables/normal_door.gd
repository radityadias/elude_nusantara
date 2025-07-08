extends AnimatableBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area: InteractionArea = $InteractionArea
@onready var main_collision: CollisionShape2D = $MainCollision

var text_to_display: String = "[E] to Open"
var is_open: bool = false

func _ready() -> void:
	interaction_area.interact = Callable(self, "_on_interact")

func _on_interact() -> void: 
	if animated_sprite_2d:
		if not is_open:
			animated_sprite_2d.play("open")
			main_collision.disabled = true
			is_open = true
			interaction_area.queue_free()

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and interaction_area:
		if not is_open:
			InteractionManager.base_text = text_to_display
