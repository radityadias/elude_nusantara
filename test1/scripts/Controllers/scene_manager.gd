# scene_manager.gd
extends Node

# Export variable to set the path to your loading screen scene in the editor
@export_file("*.tscn") var loading_screen_path: String = "res://scenes/UI/loading_screen.tscn"

# Signal to emit when a scene change is initiated (optional, but useful for UI updates)
signal scene_change_initiated(target_path: String)
# Signal to emit when the target scene has finished loading and is about to be displayed
signal scene_loaded(loaded_scene_node: Node)

# This function will be called from any other script to change scenes
func change_scene(target_scene_path: String) -> void:
	# Emit a signal that a scene change is starting
	scene_change_initiated.emit(target_scene_path)
	
	# 1. Free the current scene to clean up memory
	#    It's generally good practice to free the previous scene before loading a new one.
	if get_tree().current_scene:
		get_tree().current_scene.queue_free()
		# Important: Wait for the frame to finish to ensure current_scene is truly freed
		# This prevents potential issues if the new scene tries to access something
		# from the old scene during the same frame.
		await get_tree().process_frame

	# 2. Load the loading screen scene synchronously
	#    The loading screen itself should be very light and load instantly.
	var loading_screen_packed_scene: PackedScene = load(loading_screen_path)
	if not loading_screen_packed_scene:
		printerr("SceneManager: Failed to load loading screen scene at path: ", loading_screen_path)
		# Fallback: If loading screen fails, try to directly change to the target scene
		get_tree().change_scene_to_file(target_scene_path)
		return

	# 3. Instantiate the loading screen scene
	var loading_screen_instance: CanvasLayer = loading_screen_packed_scene.instantiate()
	
	# 4. Pass the actual target scene path to the loading screen instance
	#    The loading screen will then asynchronously load this 'target_scene_path'.
	if loading_screen_instance.has_method("set_next_scene_path"):
		loading_screen_instance.set_next_scene_path(target_scene_path)
	else:
		printerr("Loading screen instance does not have 'set_next_scene_path' method. Ensure loading_screen.gd is updated.")
		# Fallback: If the method is missing, try setting the export variable directly
		loading_screen_instance.next_scene_path = target_scene_path

	# 5. Add the loading screen instance to the root of the SceneTree
	#    This makes it immediately visible and active.
	get_tree().root.add_child(loading_screen_instance)

	# The loading_screen.gd script will now take over, display progress,
	# and eventually transition to the 'target_scene_path'.
