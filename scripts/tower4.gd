extends StaticBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var stopwatch: Node = get_node("/root/Level4/stopwatch")  # Adjust path as necessary
@onready var health_bar: ProgressBar = $health_bar  # Assuming this is your health bar progress bar

@export var health = 10000
var health_max = 10000
var health_min = 0

# Flags to track states
var is_ruined: bool = false
var is_idle: bool = false  # Track if tower is in idle state after timer runs out

func _process(delta):
	# Check if tower is in idle state (after timer runs out)
	if is_idle:
		check_level_cleared()  # Continuously check level clearance
	
	# Check if timer is running and about to expire
	if stopwatch and stopwatch.is_running:
		if stopwatch.time_left <= 1:
			# Enter idle state if not ruined
			if not is_ruined and !is_idle:
				enter_idle_state()
		else:
			is_idle = false  # Reset idle state if timer is still running

func enter_idle_state():
	animated_sprite.animation = "idle"
	is_idle = true  # Enable continuous checks
	print("Tower entered idle state.")
	
	# Remove health bar if present
	if health_bar and health_bar.is_inside_tree():
		remove_child(health_bar)
		AudioManager.play_sound_effect("timer_started")

func take_damage(amount):
	health = clamp(health - amount, health_min, health_max)
	if health_bar and health_bar.is_inside_tree():
		health_bar.value = health
	print("Tower health: ", health)
	
	# Handle tower destruction
	if health <= 0:
		is_ruined = true
		is_idle = false  # Disable idle checks
		animated_sprite.animation = "ruin"
		
		if stopwatch:
			stopwatch.time_left = 0.0
			stopwatch.is_running = false
			stopwatch.update_timer_label()
		
		if health_bar and health_bar.is_inside_tree():
			remove_child(health_bar)
			health_bar.queue_free()
		
		AudioManager.play_sound_effect("ruin")
		GameManager.remove_coins(10)

func _on_tower_area_area_entered(area: Area2D):
	if area.get_parent().has_method("player"):
		stopwatch.start()
		is_idle = false  # Reset idle state when timer restarts
		
		# Create health bar if needed
		if not has_node("health_bar") and not is_ruined:
			print("Creating new Health Bar")
			health_bar = ProgressBar.new()
			health_bar.name = "health_bar"
			health_bar.max_value = health_max
			health_bar.value = health
			add_child(health_bar)
		
		if health_bar and not is_ruined:
			print("Showing Health Bar.")
			health_bar.visible = true

func check_level_cleared():
	var enemies_remaining = get_tree().get_nodes_in_group("enemies").size()
	print("Enemies remaining:", enemies_remaining)
	if enemies_remaining == 0:
		var level_number = get_current_level_number()
		if level_number != -1:
			GameManager.clear_level(level_number)
			print("Level cleared, current unlocked levels:", GameManager.level_data.unlocked_levels)

func get_current_level_number() -> int:
	var scene_name = get_tree().current_scene.name
	match scene_name:
		"Game": return 1
		"Level2": return 2
		"Level3": return 3
		"Level4": return 4
		"Level5": return 5
	return -1

func tower():
	pass
