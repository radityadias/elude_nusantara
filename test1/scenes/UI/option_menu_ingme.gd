extends Control

@onready var sfx_slider: HSlider = $CenterContainer/Panel/VBoxContainer/AudioSlider
@onready var music_slider: HSlider = $CenterContainer/Panel/VBoxContainer/MusicSlider

func _ready():
	music_slider.value_changed.connect(_on_music_volume_changed)
	sfx_slider.value_changed.connect(_on_sfx_volume_changed)
	load_settings()
	
func _on_music_volume_changed(value: float) -> void:
	var bus_idx = AudioServer.get_bus_index("BGM")
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
	save_settings()
	
func _on_sfx_volume_changed(value: float) -> void:
	var bus_idx = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
	save_settings()

func save_settings() -> void:
	var config = ConfigFile.new()

	config.set_value("audio", "music_volume", music_slider.value)
	config.set_value("audio", "sfx_volume", sfx_slider.value)

	config.save("user://settings.cfg")

func load_settings() -> void:
	var config = ConfigFile.new()
	if config.load("user://settings.cfg") != OK:
		_on_music_volume_changed(music_slider.value)
		_on_sfx_volume_changed(sfx_slider.value)
		return

	var music_vol = config.get_value("audio", "music_volume", 0.8)
	var sfx_vol = config.get_value("audio", "sfx_volume", 0.8)
	
	music_slider.value = music_vol
	_on_music_volume_changed(music_vol)

	sfx_slider.value = sfx_vol
	_on_sfx_volume_changed(sfx_vol)

func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/UI/Popup/pause_menu.tscn")
