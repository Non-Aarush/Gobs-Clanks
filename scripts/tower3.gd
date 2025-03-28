extends StaticBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var stopwatch: Node = get_node("/root/Level3/stopwatch")  # Adjust path as necessary
@onready var health_bar: ProgressBar = $health_bar  # Assuming this is your health bar progress bar

@export var health = 8000
var health_max = 8000
var health_min = 0

# Flag to track if the tower is in ruin state
var is_ruined: bool = false

func _process(delta):
	if stopwatch and stopwatch.time_left <= 1 and stopwatch.is_running:
		# Only change animation to "idle" if the tower is not ruined
		if not is_ruined:
			animated_sprite.animation = "idle"
			# Check if health_bar is valid and inside the scene tree before removing it
			if health_bar and health_bar.is_inside_tree():
				remove_child(health_bar) 
				AudioManager.play_sound_effect("timer_started") 

func take_damage(amount):
	health = clamp(health - amount, health_min, health_max)
	if health_bar and health_bar.is_inside_tree():  # Ensure health_bar exists before accessing it
		health_bar.value = health  # Update the health bar value
	print("Tower health: ", health)  # For debugging
	
	# If tower's health reaches zero, change its state to ruin
	if health <= 0:
		is_ruined = true  # Set ruin state flag
		animated_sprite.animation = "ruin"  # Change animation to ruin
		
		# Stop the stopwatch and set time to 0:00
		if stopwatch:
			stopwatch.time_left = 0.0  # Set time left to 0
			stopwatch.is_running = false  # Stop the stopwatch
			stopwatch.update_timer_label()  # Update label to reflect time change

		# Remove the health bar from the scene tree
		if health_bar and health_bar.is_inside_tree():
			remove_child(health_bar)
			health_bar.queue_free()  # Free the node to prevent memory leaks
		
		AudioManager.play_sound_effect("ruin")
		GameManager.remove_coins(10)  # Deduct coins or add destruction logic

func _on_tower_area_area_entered(area: Area2D):
	if area.get_parent().has_method("player"):
		stopwatch.start()
		
		# Only create a new health bar if it doesn't exist and the tower isn't ruined
		if not has_node("health_bar") and not is_ruined:
			print("Creating new Health Bar")  # Debugging output
			health_bar = ProgressBar.new()  # Create a new ProgressBar if it doesn't exist
			health_bar.name = "health_bar"  # Set its name
			health_bar.max_value = health_max  # Set its max value
			health_bar.value = health  # Set its initial value
			add_child(health_bar)  # Add it as a child of the tower
		
		if health_bar and not is_ruined:  # Ensure valid instance before modifying visibility
			print("Showing Health Bar.")  # Debugging output
			health_bar.visible = true  # Show the health bar progress bar when the stopwatch starts

func tower():
	pass
