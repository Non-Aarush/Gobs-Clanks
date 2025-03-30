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
var is_audio_enabled: bool = true   # Track whether audio is enabled

func _ready():
	play_background_music(1)  # Start with background music type 1
	sfx_player.volume_db = 5.0
	ruin_player.volume_db = -5.0

# Function to play background music (with looping)
func play_background_music(type: int):
	if type == current_music_type:
		return  # Avoid restarting the same track
	
	if not music_files.has(type):
		print("Error: Music type", type, "not found!")  # Debugging message
		return
	
	var stream = music_files[type]
	
	# Enable looping for OGG files
	if stream is AudioStreamOggVorbis:
		stream.loop = true  # Set looping for the loaded stream
	
	music_player.stream = stream
	current_music_type = type  # Update current playing track
	
	if music_player.is_playing():
		music_player.stop()  # Stop current music before switching
	
	if is_audio_enabled:
		music_player.play()  # Play the new track (now looped)

# Function to toggle audio on/off
func toggle_audio():
	is_audio_enabled = !is_audio_enabled  # Toggle audio state
	if is_audio_enabled:
		print("Audio enabled")
		music_player.volume_db = 0  # Restore volume for music
		sfx_player.volume_db = 0     # Restore volume for sound effects
		ruin_player.volume_db = 0     # Restore volume for ruin sounds
		play_background_music(current_music_type)  # Resume playing background music if needed
	else:
		print("Audio muted")
		music_player.volume_db = -80  # Mute music by setting volume to -80 dB
		sfx_player.volume_db = -80     # Mute sound effects by setting volume to -80 dB
		ruin_player.volume_db = -80     # Mute ruin sounds by setting volume to -80 dB

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

	if is_audio_enabled:  # Only play sound effects if audio is enabled
		sfx_player.play()  # Play the sound effect
