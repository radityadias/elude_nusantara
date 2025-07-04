extends Area2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var press_delay: Timer = $PressDelay
@onready var animation_delay: Timer = $AnimationDelay
@onready var interaction_area: InteractionArea = $InteractionArea # Ini adalah node anak InteractionArea Anda

var is_pressed : bool = false
var can_press : bool = true
const text_to_display : String = "Reset Box"

func _ready() -> void:
	# Memastikan AudioManager tersedia
	if AudioManager == null:
		print("ERROR: AudioManager AutoLoad not found in PressButton.gd!")
	
	# Menetapkan fungsi _display_cooldown pada Callable 'interact' milik anak (child) InteractionArea
	if interaction_area: # Pastikan node anak ada
		interaction_area.interact = Callable(self, "_display_cooldown")
		print("DEBUG: PressButton: interact callable set for child InteractionArea.")
	else:
		print("ERROR: PressButton: Child InteractionArea node not found!")
	
	# Hubungkan sinyal body_entered dari node PressButton ini jika belum terhubung di editor
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
	# Pastikan sinyal body_entered dari anak InteractionArea juga terhubung ke _on_interaction_area_body_entered
	# (ini sudah ada di kode Anda)
	if interaction_area and not interaction_area.body_entered.is_connected(_on_interaction_area_body_entered):
		# Jika Anda ingin _on_interaction_area_body_entered dipicu dari child, hubungkan di sini
		# Jika tidak, ini mungkin sudah terhubung di editor
		pass 


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_pressed and can_press:
		animated_sprite_2d.play("pressed")
		is_pressed = true
		can_press = false
		animation_delay.start()
		press_delay.start()
		GameManager.box_reset()
		_display_cooldown() # Menampilkan pesan cooldown saat ditekan
		
		# --- AUDIO: Mainkan suara tombol ditekan ---
		if AudioManager:
			print("DEBUG: PressButton: Player pressed button. Playing sound.")
			AudioManager.play_sfx(AudioManager.press_sound_path, -15.0, randf_range(0.9, 1.1)) # Contoh volume dan pitch variasi
		else:
			print("ERROR: PressButton: AudioManager is NULL when trying to play button sound!")

func _on_animation_delay_timeout() -> void:
	animated_sprite_2d.play("unpressed")
	is_pressed = false
	print("DEBUG: PressButton: Animation delay timeout. Button unpressed.")

func _on_press_delay_timeout() -> void:
	can_press = true
	print("DEBUG: PressButton: Press delay timeout. Button can be pressed again.")

func _display_cooldown() -> void:
	InteractionManager.show_message("Cooldown ongoing")
	print("DEBUG: PressButton: Displaying cooldown message.")

func _on_interaction_area_body_entered(body: Node2D) -> void:
	# Fungsi ini dipicu saat player masuk ke AREA anak 'interaction_area'
	# Ini biasanya hanya untuk menampilkan teks interaksi, bukan untuk memicu suara tekan
	if body.is_in_group("player"):
		print("DEBUG: PressButton: Player entered child InteractionArea. Setting base_text.")
		InteractionManager.base_text = text_to_display
