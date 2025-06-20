extends Control

@onready var timer: Timer = $Timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var stopwatch: Label = $CanvasLayer/CenterContainer/Panel/Stopwatch
@onready var home: Button = $CanvasLayer/CenterContainer/Panel/HBoxContainer/Home
@onready var restart: Button = $CanvasLayer/CenterContainer/Panel/HBoxContainer/Restart
var saved_time: String

func _ready() -> void:
	GameManager.player_died.connect(_on_game_end)
	visible = false
	home.disabled = true
	restart.disabled = true

func _on_game_end() -> void:
	visible = true
	home.disabled = false
	restart.disabled = false
	saved_time = GameManager.get_stopwatch_time_string()
	stopwatch.text = saved_time
	animation_player.play("on")
	
func _on_restart_pressed() -> void:
	print("Restart button on Stage failed pressed")
	timer.start()
	GameManager.game_restart()  
	animation_player.play_backwards("on")
	timer.timeout.connect(func(): GameManager.game_restart())
