extends CanvasLayer

@onready var stopwatch_label = $stopwatchlabel

var time_left = 30.0
var is_running = false

func _process(delta):
	if is_running and time_left > 0:
		time_left -= delta
		update_timer_label()
	elif time_left <= 0:
		time_left = 0
		update_timer_label()
	
	update_label_position()
	update_visibility()  # Update visibility based on state

func update_timer_label():
	var minutes = int(time_left / 60)
	var seconds = int(fmod(time_left, 60))
	
	var time_string = "%02d:%02d" % [minutes, seconds]
	
	stopwatch_label.text = time_string

func update_label_position():
	stopwatch_label.position = Vector2(
		get_viewport().size.x / 2 - stopwatch_label.size.x / 2,
		20
	)

func update_visibility():
	if is_running and time_left > 0:
		stopwatch_label.visible = true  # Show the timer while it's running
	else:
		stopwatch_label.visible = false  # Hide the timer otherwise

func start():
	is_running = true

func _ready():
	stopwatch_label.size = Vector2(100, 50)
	update_label_position()
	
	# Ensure follow_viewport_enabled is false
	set_follow_viewport(false)
