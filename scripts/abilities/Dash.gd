extends Node2D  # Ensure this script extends Node2D

@export var dash_distance: float = 250.0  # Distance to dash
@export var dash_duration: float = 0.2  # Duration of the dash in seconds
@export var dash_cooldown: float = 5.0  # Cooldown duration in seconds

var is_dashing: bool = false
var can_dash: bool = true
var dash_direction: Vector2 = Vector2.ZERO
var dash_start_position: Vector2 = Vector2.ZERO
var elapsed_time: float = 0.0

func _process(delta):
	if is_dashing:
		# Update elapsed time
		elapsed_time += delta
		
		# Calculate progress (0 to 1)
		var progress = elapsed_time / dash_duration
		
		# Move player smoothly towards the target position
		var player = get_parent()  # Assuming this script is a child of the player node
		player.position = dash_start_position.lerp(dash_start_position + (dash_direction * dash_distance), progress)

		# Check if the dash duration has elapsed
		if elapsed_time >= dash_duration:
			end_dash()

	if Input.is_action_just_pressed("dash") and can_dash and not is_dashing:
		perform_dash()
		AudioManager.play_sound_effect("dash")

func perform_dash():
	var player = get_parent()  # Assuming this script is a child of the player node
	var direction = Vector2.ZERO

	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	
	if direction != Vector2.ZERO:
		direction = direction.normalized()  # Normalize to ensure consistent speed

		# Set up for dashing
		dash_direction = direction
		dash_start_position = player.position  # Store starting position for interpolation
		is_dashing = true
		can_dash = false
		elapsed_time = 0.0  # Reset elapsed time for new dash

func end_dash():
	is_dashing = false

	# Start cooldown timer to allow dashing again after `dash_cooldown`
	await get_tree().create_timer(dash_cooldown).timeout
	can_dash = true
