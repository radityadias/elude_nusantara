extends Control

@export var STARS: Array[Node]
@onready var timer: Timer = $Timer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var stopwatch: Label = $CanvasLayer/CenterContainer/Panel/Stopwatch
@onready var home: Button = $CanvasLayer/CenterContainer/Panel/HBoxContainer/Home
@onready var restart: Button = $CanvasLayer/CenterContainer/Panel/HBoxContainer/Restart
var saved_time: String

func _ready() -> void:
	GameManager.player_died.connect(_on_game_end)
	GameManager.counted_stars.connect(update_star_display)
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
	get_tree().paused = true
	
func _on_restart_pressed() -> void:
	animation_player.play_backwards("on")
	timer.start()
	timer.timeout.connect(_on_restart_timer_timeout, ConnectFlags.CONNECT_ONE_SHOT)

func _on_restart_timer_timeout():
	get_tree().paused = false
	GameManager.game_restart()

func update_star_display(value: int) -> void:
	for i in STARS.size():
		if i < value:
			STARS[i].texture = load("res://assets/Sprites/GUI/Active_Star.png")
			
