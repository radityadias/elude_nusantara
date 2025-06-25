extends Control
class_name StageComplete 

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var stopwatch: Label = $CenterContainer/Panel/Stopwatch
@export var STARS: Array[Node]
@onready var home: TextureButton = $CenterContainer/Panel/HBoxContainer/Home
@onready var next: TextureButton = $CenterContainer/Panel/HBoxContainer/Next
@onready var restart: TextureButton = $CenterContainer/Panel/HBoxContainer/Restart

func _ready() -> void:
	next.pressed.connect(_on_next_pressed)
	restart.pressed.connect(_on_restart_pressed)

	get_tree().paused = true 

	var saved_time = GameManager.get_stopwatch_time_string()
	stopwatch.text = saved_time
	animation_player.play("on")
	GameManager.counted_stars.connect(update_star_display) 

func _on_home_pressed() -> void:
	print("Button Home Pressed")
	get_tree().paused = false 
	GameManager.emit_signal("return_to_main_menu") 
	queue_free() 

func _on_next_pressed() -> void:
	print("Button next pressed")
	get_tree().paused = false 
	GameManager.emit_signal("load_next_level")
	queue_free()

func _on_restart_pressed() -> void:
	print("restart pressed")
	animation_player.play_backwards("on")
	var animation_length = animation_player.get_animation("on").length
	var timer_for_restart = Timer.new()
	add_child(timer_for_restart)
	timer_for_restart.wait_time = animation_length
	timer_for_restart.one_shot = true
	timer_for_restart.timeout.connect(func():
		get_tree().paused = false 
		GameManager.game_restart()
		queue_free()
	)
	timer_for_restart.start()

func update_star_display(value: int) -> void:
	for i in STARS.size():
		if i < value:
			if STARS[i] is TextureRect:
				(STARS[i] as TextureRect).texture = load("res://assets/Sprites/GUI/Active_Star.png")
			else:
				push_warning("STARS array contains non-TextureRect nodes or similar.")
