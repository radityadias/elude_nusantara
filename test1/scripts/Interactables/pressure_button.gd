extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var press_delay: Timer = $PressDelay
@onready var animation_delay: Timer = $AnimationDelay
@onready var interaction_area: InteractionArea = $InteractionArea

var is_pressed : bool = false
var can_press : bool = true
const text_to_display : String = "Reset Box"

func _ready() -> void:
	interaction_area.interact = Callable(self, "_display_cooldown")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_pressed and can_press:
		animated_sprite_2d.play("pressed")
		is_pressed = true
		can_press = false
		animation_delay.start()
		press_delay.start()
		GameManager.box_reset()
		_display_cooldown()

func _on_animation_delay_timeout() -> void:
	animated_sprite_2d.play("unpressed")
	is_pressed = false

func _on_press_delay_timeout() -> void:
	can_press = true

func _display_cooldown() -> void:
	InteractionManager.show_message("Cooldown ongoing")

func _on_interaction_area_body_entered(body: Node2D) -> void:
	InteractionManager.base_text = text_to_display
