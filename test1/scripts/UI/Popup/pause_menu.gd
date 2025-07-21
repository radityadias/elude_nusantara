extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var resume_button: Button = $PanelContainer/VBoxContainer/Resume
@onready var restart: Button = $PanelContainer/VBoxContainer/Restart
@onready var quit: Button = $PanelContainer/VBoxContainer/Quit

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	try_pause()

func resume() -> void:
	get_tree().paused = false
	animation_player.play_backwards("blur")
	queue_free()

func pause() -> void: 
	get_tree().paused = true
	animation_player.play("blur")

func try_pause() -> void:
	if Input.is_action_just_pressed("Escape") and get_tree().paused == false:
		pause()
	elif Input.is_action_just_pressed("Escape") and get_tree().paused == true:
		resume()

func _on_resume_pressed() -> void:
	resume()

func _on_restart_pressed() -> void:
	resume()
	get_tree().reload_current_scene()
	
func _on_option_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/Popup/option_menu_ingme.tscn")
	
func _on_quit_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scripts/UI/MainMenu/level_select.gd")
