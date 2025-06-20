extends Control
class_name PauseMenu

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var game_manager: Node = %GameManager
@onready var timer: Timer = $Timer
@onready var stopwatch: Label = $CanvasLayer/CenterContainer/Panel/Stopwatch
@export var STARS: Array[Node]
var saved_time: String

func _ready() -> void:
	GameManager.game_finished.connect(_on_game_finished)
	GameManager.counted_stars.connect(update_star_display)

func _on_home_pressed() -> void:
	print("Button Home Pressed")

func _on_next_pressed() -> void:
	print("Button next presseds")

func _on_restart_pressed() -> void:
	timer.start()
	animation_player.play_backwards("on")
	timer.timeout.connect(func(): GameManager.game_restart())

func _on_game_finished() -> void:
	print("Game Finished, Display the UI Stage Complete")
	saved_time = GameManager.get_stopwatch_time_string()
	stopwatch.text = saved_time
	animation_player.play("on")

func update_star_display(value: int) -> void:
	print("Star received: ", value)
	for i in STARS.size():
		if i < value:
			STARS[i].texture = load("res://assets/Sprites/GUI/Active_Star.png")
