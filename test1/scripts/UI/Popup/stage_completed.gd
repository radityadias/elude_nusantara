extends Control
class_name StageComplete 

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var stopwatch: Label = $CenterContainer/Panel/Stopwatch
@export var STARS: Array[Node]
@onready var home: TextureButton = $CenterContainer/Panel/HBoxContainer/Home
@onready var next: TextureButton = $CenterContainer/Panel/HBoxContainer/Next
@onready var restart: TextureButton = $CenterContainer/Panel/HBoxContainer/Restart

var initial_stars: int = 0 
var base_path: String = "res://scenes/levels/level_"

func _ready() -> void:
	next.pressed.connect(_on_next_pressed)
	restart.pressed.connect(_on_restart_pressed)

	print("Initial Stars: ", initial_stars)
	update_star_display(initial_stars)
	var saved_time = GameManager.get_stopwatch_time_string()
	stopwatch.text = saved_time
	animation_player.play("on")
	get_tree().paused = true 

func set_initial_stars(value: int) -> void:
	initial_stars = value

func _on_home_pressed() -> void:
	print("Button Home Pressed")
	get_tree().paused = false 
	get_tree().change_scene_to_file("res://scenes/UI/MainMenu/level_select.tscn")
	queue_free() 

func _on_next_pressed() -> void:
	print("Button next pressed")
	get_tree().paused = false 
	GameManager.next_level()
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
	print("Stars received: ", value)
	for i in STARS.size():
		if STARS[i] is TextureRect: # Always check the type
			var star_texture_rect = STARS[i] as TextureRect
			if i < value:
				star_texture_rect.texture = load("res://assets/Sprites/GUI/Active_Star.png")
			else:
				star_texture_rect.texture = load("res://assets/Sprites/GUI/Unactive_Star.png")
		else:
			push_warning("STARS array contains non-TextureRect nodes at index %d. Skipping." % i)
