extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer

func _ready() -> void:
	GameManager.game_finished.connect(on_game_finished)

func on_game_finished() -> void:
	animation_player.play("on")

func _on_home_pressed() -> void:
	print("Home Button Pressed")


func _on_next_pressed() -> void:
	print("Next Button Pressed")


func _on_restart_pressed() -> void:
	print("Restartd  Button Pressed")
