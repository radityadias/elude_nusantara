extends Area2D

func _ready() -> void:
	# --- Memastikan AudioManager tersedia ---
	if AudioManager == null:
		push_error("ERROR: AudioManager AutoLoad not found in JumpPad script!")

func _on_body_entered(body: Node2D) -> void:
	# Pastikan hanya Player yang memicu suara dan fungsi jump pad
	if body.has_method("get_input_direction"): # Contoh cara cek apakah ini player
		GameManager.using_jumppad()

		# --- AUDIO: Mainkan suara jump pad ---
		if AudioManager: # Pastikan AudioManager tidak null
			AudioManager.play_sfx(AudioManager.jump_pad_sound_path, -10.0, randf_range(0.9, 1.1))
		else:
			push_error("ERROR: AudioManager not found when trying to play jump pad sound!")
