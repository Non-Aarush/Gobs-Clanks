extends CanvasLayer

@onready var stopwatch_label = $stopwatchlabel

var time_left = 30.0
var is_running = false
var current_music_type = -1  # Track current music type to avoid unnecessary replays

func _process(delta):
	if is_running and time_left > 0:
		time_left -= delta
		update_timer_label()
	elif time_left <= 0:
		time_left = 0
		is_running = false
	
	update_label_position()
	update_visibility()
	update_music()

func update_timer_label():
	var minutes = int(time_left / 60)
	var seconds = int(fmod(time_left, 60))
	
	stopwatch_label.text = "%02d:%02d" % [minutes, seconds]

func update_label_position():
	stopwatch_label.position = Vector2(
		get_viewport().size.x / 2 - stopwatch_label.size.x / 2,
		20
	)

func update_visibility():
	stopwatch_label.visible = is_running and time_left > 0

func update_music():
	var target_music = 2 if stopwatch_label.visible else 1
	
	if target_music != current_music_type:  # Only switch if different
		current_music_type = target_music
		AudioManager.play_background_music(current_music_type)  

func start():
	is_running = true

func _ready():
	stopwatch_label.size = Vector2(100, 50)
	update_label_position()
	
	# Ensure follow_viewport_enabled is false
	set_follow_viewport(false)
