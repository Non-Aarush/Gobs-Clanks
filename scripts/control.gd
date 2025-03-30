extends CanvasLayer

@onready var home_button = $HomeButton
@onready var sound_button = $SoundButton

func _ready():
	print("Global UI is ready!")  # Debugging output
	position_buttons()  # Position buttons initially

	# Connect size_changed signal to update button positions on resize
	get_tree().root.connect("size_changed", Callable(self, "position_buttons"))

func position_buttons():
	var viewport_size = get_viewport().get_visible_rect().size  # Correct method to get viewport size

	# Position HomeButton at top-right corner
	if home_button != null:
		var home_button_size = home_button.size
		home_button.position = Vector2(viewport_size.x - home_button_size.x - 10, 10)  # Top-right with padding

	# Position SoundButton at bottom-left corner
	if sound_button != null:
		var sound_button_size = sound_button.size
		sound_button.position = Vector2(10, viewport_size.y - sound_button_size.y - 10)  # Bottom-left with padding
