extends Node2D  # Use Node2D as the base class

@export var push_force: float = 11000.0  # Increased force applied to push enemies away (3x original)
@export var radius: float = 200.0  # Radius of the wind gust effect
@export var cooldown_duration: float = 5.0  # Cooldown duration in seconds
@export var shake_duration: float = 0.2  # Duration of screen shake
@export var shake_magnitude: float = 5.0  # Reduced magnitude of screen shake

var can_use_ability: bool = true  # Tracks whether the ability can be used

func _process(delta):
	if Input.is_action_just_pressed("gust") and can_use_ability:
		activate_ability()

func activate_ability():
	print("Activating Wind Gust!")  # Debug message
	can_use_ability = false

	# Push enemies away
	push_enemies_away()

	# Start screen shake effect
	await start_screen_shake()

	# Reset ability after cooldown
	await get_tree().create_timer(cooldown_duration).timeout
	can_use_ability = true

func push_enemies_away():
	print("Checking for enemies to push...")
	var enemies = get_tree().get_nodes_in_group("enemies")  # Get all nodes in the "enemies" group

	for enemy in enemies:
		if is_instance_valid(enemy):
			var parent_body = enemy.get_parent() if enemy.has_method("get_parent") else enemy  # Get parent if possible
			
			if parent_body is CharacterBody2D:  # Ensure parent is a CharacterBody2D
				print("Found CharacterBody2D:", parent_body.name)
				var distance = global_position.distance_to(parent_body.global_position)
				print("Distance to enemy:", distance)

				if distance <= radius:
					print("Enemy within radius:", parent_body.name)
					var direction = (parent_body.global_position - global_position).normalized()
					print("Push direction:", direction)

					# Apply force to enemy's velocity
					parent_body.velocity += direction * push_force  
					
					print("Applied force to enemy:", parent_body.name, "New velocity:", parent_body.velocity)
				else:
					print("Enemy outside radius:", parent_body.name)
			else:
				print("Invalid or non-CharacterBody2D node detected.")
		else:
			print("Invalid or non-instance enemy detected.")

func start_screen_shake() -> void:
	var camera = get_viewport().get_camera_2d()  # Get the Camera2D to apply shake
	if camera:
		var original_position = camera.position  # Save original position
		
		for i in range(int(shake_duration / (1 / Engine.get_frames_per_second()))): 
			camera.position = original_position + Vector2(
				randf_range(-shake_magnitude, shake_magnitude),  # Reduced shake magnitude
				randf_range(-shake_magnitude, shake_magnitude)   # Reduced shake magnitude
			)
			await get_tree().create_timer(1 / Engine.get_frames_per_second()).timeout  # Wait for a frame

		camera.position = original_position  # Reset camera position after shake
