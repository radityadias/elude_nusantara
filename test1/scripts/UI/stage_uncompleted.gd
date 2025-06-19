extends Control

@onready var timer: Timer = $Timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var stopwatch: Label = $CanvasLayer/CenterContainer/Panel/Stopwatch
var saved_time: String


func _ready() -> void:
	GameManager.player_died.connect(_on_game_end)

func _on_game_end() -> void:
	saved_time = GameManager.get_stopwatch_time_string()
	stopwatch.text = saved_time
	animation_player.play("on")
	
func _on_restart_pressed() -> void:
	timer.start()
	GameManager.game_restart()  
	animation_player.play_backwards("on")
	timer.timeout.connect(func(): GameManager.game_restart())
