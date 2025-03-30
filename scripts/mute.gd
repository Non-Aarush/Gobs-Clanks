extends TextureButton

@onready var sound_on_texture = preload("res://mute.png")  # Replace with your "sound on" texture path
@onready var sound_off_texture = preload("res://unmute.png")  # Replace with your "sound off" texture path

func _ready():
	self.connect("pressed", Callable(self, "_on_pressed"))
	update_button_texture()  # Set initial texture based on audio state

func _on_pressed() -> void:
	AudioManager.toggle_audio()  # Toggle audio using AudioManager
	update_button_texture()  # Update button texture based on new audio state

func update_button_texture():
	if AudioManager.is_audio_enabled:
		self.texture_normal = sound_on_texture  # Change to "sound on" icon
		print("Sound turned ON")
	else:
		self.texture_normal = sound_off_texture  # Change to "sound off" icon
		print("Sound turned OFF")
