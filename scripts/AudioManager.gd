extends Node

@onready var music_player: AudioStreamPlayer = $MusicPlayer

# Preload music files once (better performance)
var music_files = {
	1: preload("res://background1.ogg"),  # Replace with actual path
	2: preload("res://Background2.ogg")   # Replace with actual path
}

var current_music_type: int = -1  # Track currently playing music

func _ready():
	play_background_music(1)  # Start with background music type 1

# Function to play background music
func play_background_music(type: int):
	if type == current_music_type:
		return  # Avoid restarting the same track
	
	if not music_files.has(type):
		print("Error: Music type", type, "not found!")  # Debugging message
		return
	
	music_player.stream = music_files[type]  
	current_music_type = type  # Update current playing track
	
	if music_player.is_playing():
		music_player.stop()  # Stop current music before switching
	
	music_player.play()
