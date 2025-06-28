extends Sprite2D

var has_fallen: bool = false
var initial_position: Vector2
@onready var main_collision: CollisionShape2D = $StaticBody2D/MainCollision
@onready var timer: Timer = $Timer

func _ready() -> void:
	initial_position = global_position # Store it when the node is ready
	modulate.a = 1.0 # Ensure it starts fully visible

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not has_fallen:
		var opacity_tween: Tween = create_tween().set_trans(Tween.TRANS_SINE)
		var pos_tween: Tween = create_tween().set_trans(Tween.TRANS_SINE)
		
		opacity_tween.tween_property(self, "modulate:a", 0.0, 0.5)
		pos_tween.tween_property(self, "global_position", global_position + Vector2(0, 20), 0.5)
		
		opacity_tween.finished.connect(disable_collision)
		
		has_fallen = true

func disable_collision() ->  void:
	main_collision.disabled = true
	timer.start()

func _on_timer_timeout() -> void:
# Immediately reset position (or tween it back up) and disable collision while fading in
	global_position = initial_position
	modulate.a = 0.0 # Set alpha to 0 to start fading in from invisible
	
	var fade_in_tween: Tween = create_tween().set_trans(Tween.TRANS_SINE)
	fade_in_tween.tween_property(self, "modulate:a", 1.0, 0.5) # Fade in over 0.5 seconds
	
	# Connect a signal to re-enable collision AFTER the fade-in is complete
	fade_in_tween.finished.connect(re_enable_platform)

func re_enable_platform() -> void:
	main_collision.disabled = false
	has_fallen = false
