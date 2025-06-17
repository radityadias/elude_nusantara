extends Control
class_name PauseMenu

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var game_manager: Node = %GameManager
@onready var timer: Timer = $Timer
@onready var stopwatch: Label = $CanvasLayer/CenterContainer/Panel/Stopwatch
var saved_time: String

func _ready() -> void:
	GameManager.game_finished.connect(_on_game_finished)

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
