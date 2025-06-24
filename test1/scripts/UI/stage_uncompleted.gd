extends Control
class_name StageFailed 

@export var STARS: Array[Node]
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var stopwatch: Label = $CenterContainer/Panel/Stopwatch
@onready var home: Button = $CenterContainer/Panel/HBoxContainer/Home
@onready var restart: Button = $CenterContainer/Panel/HBoxContainer/Restart

func _ready() -> void:
	print("Function ready get called!")
	animation_player.play("on")
	get_tree().paused = true
	var saved_time = GameManager.get_stopwatch_time_string()
	stopwatch.text = saved_time
	
 
func update_star_display(value: int) -> void:
	for i in STARS.size():
		if i < value:
			if STARS[i] is TextureRect: # Ensure it's a TextureRect or similar
				(STARS[i] as TextureRect).texture = load("res://assets/Sprites/GUI/Active_Star.png")
			else:
				push_warning("STARS array contains non-TextureRect nodes or similar.")


func _on_home_pressed() -> void:
	print("Home Button Pressed!")
	
func _on_restart_pressed() -> void:
	print("Restart button pressed!")
	animation_player.play_backwards("on")
	# Connect the timeout signal to trigger the restart AFTER the animation finishes
	var animation_length = animation_player.get_animation("on").length
	# You can use a Timer node or a one-shot connection to the AnimationPlayer's `animation_finished` signal
	# I'll use a direct timeout connection for simplicity, assuming the animation is "on"
	var timer_for_restart = Timer.new()
	add_child(timer_for_restart)
	timer_for_restart.wait_time = animation_length
	timer_for_restart.one_shot = true
	timer_for_restart.timeout.connect(func():
		get_tree().paused = false # Unpause game
		GameManager.game_restart() # This signal likely reloads the current scene
		# Important: `queue_free()` this UI node after signaling and restarting
		# The scene reload will effectively remove this node anyway, but explicit free is good.
		queue_free()
	)
	timer_for_restart.start() 
