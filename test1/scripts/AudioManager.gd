# AudioManager.gd
extends Node

# --- EXPORT VARIABLES (SET IN EDITOR AFTER AUTOLOAD IS CONFIGURED) ---
@export var jump_sound_path: String = "res://assets/SFX ELUDE/Character/JUMPING.wav" # <-- UBAH PATH INI
@export var run_step_sound_path: String = "res://assets/SFX ELUDE/Character/FOOTSTEP RUNNING ORI.wav" # <-- UBAH PATH INI
@export var default_bgm_path: String = "res://assets/SFX ELUDE/BGM/BGMmain.mp3" # <-- UBAH PATH INI
@export var death_sound_path: String = "res://assets/SFX ELUDE/Character/DIE.wav" # <-- TAMBAHKAN BARIS INI
@export var hit_sound_path: String = "res://assets/SFX ELUDE/Character/ON hit.wav"
@export var door_open_sound_path: String = "res://assets/SFX ELUDE/Interactables/DOOR OPEN.mp3" # <-- TAMBAHKAN BARIS INI
@export var jump_pad_sound_path: String = "res://assets/SFX ELUDE/Character/Jump pad.wav"
@export var card_collect_sound_path: String = "res://assets/SFX ELUDE/Interactables/cardCollect.wav" # <-- TAMBAHKAN BARIS INI
@export var scanner_sound_path: String = "res://assets/SFX ELUDE/Interactables/cardCollect3.wav"
@export var press_sound_path: String = "res://assets/SFX ELUDE/Interactables/PRESS BUTTON.wav"
@export var dragging_sound_path: String = "res://assets/SFX ELUDE/Interactables/DRAGGING N PUSHING OBJECT.wav"
@export var win_sound_path: String = "res://assets/SFX ELUDE/BGM/Win.wav"
@export var lose_sound_path: String = "res://assets/SFX ELUDE/BGM/LOSE.wav"

# --- NODE REFERENCES ---
var sfx_player_pool: Array[AudioStreamPlayer] = []
var max_sfx_players: int = 15 # Batasan jumlah AudioStreamPlayer untuk SFX (bisa disesuaikan)
var music_player: AudioStreamPlayer # AudioStreamPlayer khusus untuk musik latar

func _ready():
	# Pastikan AudioManager hanya diinisialisasi sekali (jika AutoLoad)
	if not Engine.is_editor_hint() and self != get_node("/root/AudioManager"):
		queue_free()
		return
	
	# Inisialisasi SFX player pool
	for i in max_sfx_players:
		var player = AudioStreamPlayer.new()
		player.bus = "SFX" # Mengarahkan semua SFX ke bus "SFX"
		add_child(player)
		sfx_player_pool.append(player)
		player.finished.connect(_on_sfx_finished.bind(player), CONNECT_ONE_SHOT)
	
	# Inisialisasi Music player
	music_player = AudioStreamPlayer.new()
	music_player.bus = "BGM" # Mengarahkan musik ke bus "Music"
	add_child(music_player)
	
	# Memutar musik latar default saat game dimulai (opsional)
	if default_bgm_path and not default_bgm_path.is_empty():
		play_music(default_bgm_path, -10.0) # Contoh volume untuk BGM

## =========================================================
## SFX MANAGEMENT
## =========================================================

## Mengambil AudioStreamPlayer yang bebas dari pool.
func _get_free_sfx_player() -> AudioStreamPlayer:
	for player in sfx_player_pool:
		if not player.playing:
			return player
	
	# Jika pool habis, buat player baru jika belum mencapai batas total (SFX + Music player)
	if get_child_count() < max_sfx_players + 1: # +1 untuk music_player
		var new_player = AudioStreamPlayer.new()
		new_player.bus = "SFX"
		add_child(new_player)
		sfx_player_pool.append(new_player)
		new_player.finished.connect(_on_sfx_finished.bind(new_player), CONNECT_ONE_SHOT)
		return new_player
	
	push_warning("Warning: SFX player pool exhausted and max players reached. Cannot play new SFX.")
	return null

## Memutar SFX satu kali (misal: jump, hit, UI click).
func play_sfx(audio_path: String, volume_db: float = 0.0, pitch_scale: float = 1.0):
	var player = _get_free_sfx_player()
	if player:
		player.stream = load(audio_path)
		player.volume_db = volume_db
		player.pitch_scale = pitch_scale
		player.play()
	else:
		push_warning("AudioManager: WARNING: No free SFX player available to play: ", audio_path) # <-- PASTIKAN INI ADA
		
		
## Memutar SFX yang akan di-loop (misal: suara lari).
## PENTING: File audio harus diatur 'Loop' di import settings Godot.
## Panggil stop_looped_sfx() saat loop harus berhenti.
func play_looped_sfx(audio_path: String, volume_db: float = 0.0, pitch_scale: float = 1.0):
	var player = _get_free_sfx_player()
	if player:
		var audio_stream = load(audio_path)
		if audio_stream is AudioStream:
			player.stream = audio_stream
			player.volume_db = volume_db
			player.pitch_scale = pitch_scale
			# Properti loop diatur di import settings file audio
			# print("Playing Looped SFX: ", audio_path, " with volume_db: ", volume_db, " and pitch: ", pitch_scale)
			if not player.playing or player.stream != audio_stream:
				player.play()
		else:
			push_warning("Warning: Failed to load AudioStream for looped SFX: ", audio_path)

## Menghentikan SFX yang sedang di-loop berdasarkan path audio.
func stop_looped_sfx(audio_path: String):
	for player in sfx_player_pool:
		if player.playing and player.stream:
			var current_stream = player.stream
			if current_stream == load(audio_path):
				player.stop()
				_return_sfx_player_to_pool(player)
				return

## Callback saat AudioStreamPlayer selesai memutar suara (untuk SFX non-loop).
func _on_sfx_finished(player: AudioStreamPlayer):
	_return_sfx_player_to_pool(player)

## Mengembalikan AudioStreamPlayer ke pool untuk digunakan kembali.
func _return_sfx_player_to_pool(player: AudioStreamPlayer):
	if not player.is_queued_for_deletion() and player in sfx_player_pool: # Pastikan player valid dan masih di pool
		player.stream = null # Hapus stream untuk membebaskan memori
		player.volume_db = 0.0 # Reset volume

## =========================================================
## MUSIC MANAGEMENT
## =========================================================

## Memutar musik latar. Otomatis di-loop (file audio harus diatur loop di import settings).
func play_music(audio_path: String, volume_db: float = 0.0):
	var new_stream = load(audio_path)
	if new_stream is AudioStream:
		# Hanya ganti musik jika berbeda atau tidak sedang diputar
		if music_player.stream != new_stream or not music_player.playing:
			music_player.stream = new_stream
			music_player.volume_db = volume_db
			music_player.play()
			# print("Playing BGM: ", audio_path, " with volume_db: ", volume_db)
			
			if new_stream is AudioStreamOggVorbis or new_stream is AudioStreamWAV:
				if not new_stream.loop:
					push_warning("Warning: BGM stream is not set to loop in import settings: ", audio_path)
	else:
		push_error("Error: Could not load AudioStream for BGM: ", audio_path)

## Menghentikan musik latar.
func stop_music():
	if music_player.playing:
		music_player.stop()
		music_player.stream = null # Hapus stream

## Mengatur volume bus Music secara global (0.0 - 1.0 linear scale).
func set_music_volume(volume_linear: float):
	var bus_idx = AudioServer.get_bus_index("Music")
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(volume_linear))
		# print("Music bus volume set to: ", volume_linear, " (", linear_to_db(volume_linear), " dB)")

## Mendapatkan volume bus Music secara global (0.0 - 1.0 linear scale).
func get_music_volume() -> float:
	var bus_idx = AudioServer.get_bus_index("Music")
	if bus_idx != -1:
		return db_to_linear(AudioServer.get_bus_volume_db(bus_idx))
	return 0.0

## Mengatur volume bus SFX secara global (0.0 - 1.0 linear scale).
func set_sfx_volume(volume_linear: float):
	var bus_idx = AudioServer.get_bus_index("SFX")
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(volume_linear))
		# print("SFX bus volume set to: ", volume_linear, " (", linear_to_db(volume_linear), " dB)")

## Mendapatkan volume bus SFX secara global (0.0 - 1.0 linear scale).
func get_sfx_volume() -> float:
	var bus_idx = AudioServer.get_bus_index("SFX")
	if bus_idx != -1:
		return db_to_linear(AudioServer.get_bus_volume_db(bus_idx))
	return 0.0

func stop_all_looped_sfx():
	for player in sfx_player_pool:
		if is_instance_valid(player) and player.playing and player.loop:
			player.stop()
			player.loop = false # Reset loop flag
			player.stream = null # Hapus stream
			player.volume_db = 0.0 # Reset volume
			player.pitch_scale = 1.0 # Reset pitch
