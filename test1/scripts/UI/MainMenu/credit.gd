extends Control

# Hubungkan ke node yang akan kita gerakkan
@onready var container = $CreditContainer

# Kecepatan scroll dalam piksel per detik
var scroll_speed: float = 80.0

func _ready():
	# Atur posisi awal container tepat di bawah layar
	container.position.y = get_viewport_rect().size.y

func _process(delta: float):
	container.position.y -= scroll_speed * delta

	var container_bottom = container.position.y + container.size.y
	if container_bottom < 0:
		return_to_main_menu()

func _input(event: InputEvent):
	if event.is_action_pressed("ui_cancel"):
		return_to_main_menu()

func return_to_main_menu():
	get_tree().change_scene_to_file("res://scenes/UI/MainMenu/main_menu.tscn")
