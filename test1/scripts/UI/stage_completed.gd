extends Control
class_name StageFailed

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var game_manager: Node = %GameManager
@onready var timer: Timer = $Timer
@onready var stopwatch: Label = $CanvasLayer/CenterContainer/Panel/Stopwatch
@export var STARS: Array[Node]
@onready var home: Button = $CanvasLayer/CenterContainer/Panel/HBoxContainer/Home
@onready var next: Button = $CanvasLayer/CenterContainer/Panel/HBoxContainer/Next
@onready var restart: Button = $CanvasLayer/CenterContainer/Panel/HBoxContainer/Restart

var saved_time: String

func _ready() -> void:
	GameManager.game_finished.connect(_on_game_finished)
	GameManager.counted_stars.connect(update_star_display)
	visible = false
	home.disabled = true
	next.disabled = true
	restart.disabled = true

func _on_home_pressed() -> void:
	print("Button Home Pressed")

func _on_next_pressed() -> void:
	print("Button next presseds")

func _on_restart_pressed() -> void:
	timer.start()
	animation_player.play_backwards("on")
	timer.timeout.connect(func(): GameManager.game_restart())
	get_tree().paused = false

func _on_game_finished() -> void:
	visible = true
	home.disabled = false
	next.disabled = false
	restart.disabled = false
	saved_time = GameManager.get_stopwatch_time_string()
	stopwatch.text = saved_time
	animation_player.play("on")
	get_tree().paused = true

func update_star_display(value: int) -> void:
	for i in STARS.size():
		if i < value:
			STARS[i].texture = load("res://assets/Sprites/GUI/Active_Star.png")
