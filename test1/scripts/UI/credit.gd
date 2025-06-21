extends Control

@onready var container := $ScrollContainer/CreditContainer
@onready var anim_back = $AnimatedSprite2D

var scroll_speed := 50 # Kecepatan scroll (pixel per detik)

func _ready():
	# Mulai dari bawah layar
	container.position.y = get_viewport().get_visible_rect().size.y
	anim_back.play("Background")

func _process(delta):
	container.position.y -= scroll_speed * delta
	
	var container_bottom = container.position.y + container.size.y
	if container_bottom < 0: 
		get_tree().change_scene_to_file("res://Main_menu.tscn")
