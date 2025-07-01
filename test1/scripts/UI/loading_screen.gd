extends CanvasLayer

@export_file("*.tscn") var next_scene_path: String = "" # Path to the scene to load
@export var fade_duration: float = 0.5 # Duration for fade in/out animations

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var loading_timer: Timer = $LoadingTimer

var is_loading_started: bool = false
var loading_successful: bool = false # This flag will be key to preventing double calls
var loaded_scene: PackedScene = null

func _ready() -> void:
	print("Loading Screen _ready func executed!")
	if animation_player:
		animation_player.play("fade_in")
		print("Fade in animation executed")
		await animation_player.animation_finished
		loading_timer.start()
	
	start_loading()

func start_loading() -> void:
	if next_scene_path.is_empty():
		printerr("LoadingScreen: next_scene_path is not set!")
		return

	is_loading_started = true
	ResourceLoader.load_threaded_request(next_scene_path)
	set_process(true) # Ensure _process is running to monitor loading

func _process(delta: float) -> void:
	# Add a check here: if loading is already successfully done, stop processing
	if loading_successful: # Added this check
		set_process(false)
		return

	if not is_loading_started:
		return

	var progress_array = []
	var status = ResourceLoader.load_threaded_get_status(next_scene_path, progress_array)

	match status:
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			var current_progress: float = 0.0
			if not progress_array.is_empty():
				current_progress = progress_array[0]


		ResourceLoader.THREAD_LOAD_LOADED:
			# Crucial change: Only proceed if loading_successful is not true yet
			if not loading_successful: # Added this check
				loaded_scene = ResourceLoader.load_threaded_get(next_scene_path)
				if loaded_scene:
					loading_successful = true # Set the flag to true immediately
					loading_timer.timeout.connect(transition_to_next_scene) 
				else:
					printerr("LoadingScreen: Failed to load scene: ", next_scene_path)
					set_process(false) # Stop processing if loading failed
			
		ResourceLoader.THREAD_LOAD_FAILED:
			printerr("LoadingScreen: Threaded loading failed for: ", next_scene_path)
			set_process(false)

func transition_to_next_scene() -> void:
	set_process(false) # Stop monitoring progress, but this is less critical now due to the flag

	if animation_player:
		animation_player.play("fade_out")
		print("Fade Out animation executed!")
		await animation_player.animation_finished
	
	if loaded_scene:
		get_tree().change_scene_to_packed(loaded_scene)
		queue_free()
	else:
		printerr("LoadingScreen: Attempted to transition to a null scene.")

func set_next_scene_path(path: String) -> void:
	next_scene_path = path
	if not is_loading_started:
		start_loading()
