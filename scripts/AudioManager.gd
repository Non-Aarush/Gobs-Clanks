extends Node

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer
@onready var ruin_player: AudioStreamPlayer = $RuinPlayer
# Preload music files once (better performance)
var music_files = {
	1: preload("res://background1.ogg"),  # Replace with actual path
	2: preload("res://Background2.ogg")   # Replace with actual path
}

var current_music_type: int = -1  # Track currently playing music

func _ready():
	play_background_music(1)  # Start with background music type 1
	sfx_player.volume_db = 15.0
	ruin_player.volume_db = 5  # Set SFX volume to +6 dB (increase as needed)

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

func play_sound_effect(effect_name: String):
	match effect_name:
		"attack":
			sfx_player.stream = preload("res://music/attack.wav")
		"invis":
			sfx_player.stream = preload("res://music/invis.wav")
		"heal":
			sfx_player.stream = preload("res://music/heal.wav")
		"lightning":
			sfx_player.stream = preload("res://music/thunder.wav")
		"dash":
			sfx_player.stream = preload("res://music/dash.wav")
		"gust":
			sfx_player.stream = preload("res://music/gust.wav")
		"hit":
			sfx_player.stream = preload("res://music/hit.wav")
		"goblin_death":
			sfx_player.stream = preload("res://music/goblin_death.wav")
		"timer_started":
			sfx_player.stream = preload("res://music/timer_started.wav")
		"play":
			sfx_player.stream = preload("res://music/play.wav")
		"quit":
			sfx_player.stream = preload("res://music/quit.wav")
		"explo":
			sfx_player.stream = preload("res://music/explosion.wav")
		"ruin":
			ruin_player.stream = preload("res://music/ruin.wav")
			ruin_player.play()

	sfx_player.play()  # Play the sound effect
