extends TextureButton

func _ready():
	# Connect pressed signal
	self.connect("pressed", Callable(self, "_on_pressed"))

func _on_pressed() -> void:
	print("Home button pressed!")
	cleanup_enemies()  # Call the cleanup function before changing scenes
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")  # Change to your main menu scene

func cleanup_enemies():
	# Iterate through all nodes in the scene tree
	for enemy in get_tree().get_nodes_in_group("enemies"):
		enemy.queue_free()  # Remove each enemy from the scene
	print("All enemies have been removed.")
