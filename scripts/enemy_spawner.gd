# Enemy Spawner Script

extends Node2D

@export var enemy_scene: PackedScene  # Load the enemy scene as a packed scene
@onready var stopwatch: Node = get_node("/root/Game/stopwatch")  # Reference to the stopwatch node
@onready var stopwatch_label = stopwatch.get_node("stopwatchlabel")  # Reference to the stopwatch label
@onready var player = get_tree().get_nodes_in_group("player")[0]  # Reference to the player node

var max_enemies = 8  # Maximum number of active enemies
var current_enemies = 0  # Current number of active enemies
var spawn_interval = 3.5  # Reduced spawn interval for faster spawning
var spawn_timer = spawn_interval  # Initialize spawn timer
var initial_delay = 0.5  # Initial delay
var delay_timer = 0.0
var stopwatch_started = false  # Flag to track if stopwatch has started
var spawning_allowed = false  # Flag to control spawning

func _process(delta):
	if stopwatch_label.visible:  # Check if stopwatch label is visible
		if not stopwatch_started:  # If stopwatch just started
			stopwatch_started = true
			delay_timer = 0.0  # Reset delay timer
			spawning_allowed = false  # Reset spawning allowance
		
		delay_timer += delta
		
		if delay_timer >= initial_delay:
			spawning_allowed = true  # Allow spawning after delay
		
		if spawning_allowed:
			spawn_timer -= delta
			
			if spawn_timer <= 0 and current_enemies < max_enemies:
				spawn_enemy()
				spawn_timer = spawn_interval
	else:  # If stopwatch label is not visible
		spawning_allowed = false  # Prevent further spawning
		spawn_timer = 0.0  # Reset spawn timer

func spawn_enemy():
	var random_distance = randi() % 10 + 1  # Random distance between 1 and 10 tiles
	var random_angle = randf_range(0, 2 * PI)  # Random angle
	
	var enemy_position = player.position + Vector2(
		cos(random_angle) * random_distance * 16,  # Assuming 16x16 tiles
		sin(random_angle) * random_distance * 16
	)
	
	# Ensure the spawn position is within bounds
	if enemy_position.x > 0 and enemy_position.x < get_viewport().size.x and enemy_position.y > 0 and enemy_position.y < get_viewport().size.y:
		var enemy_instance = enemy_scene.instantiate()
		
		# Correctly set the parent to the game scene
		enemy_instance.set_script(load("res://scripts/goblin.gd"))  # Load the goblin script
		
		enemy_instance.position = enemy_position
		
		# Add the enemy to the main scene
		get_tree().get_root().add_child(enemy_instance)
		
		# Ensure the enemy script is executed
		if enemy_instance.has_method("init"):
			enemy_instance.init()
		
		# Add to groups if necessary
		if not enemy_instance.is_in_group("enemies"):
			enemy_instance.add_to_group("enemies")
		
		current_enemies += 1
		print("Enemy spawned at position:", enemy_position)  # Debug message
	else:
		print("Enemy spawn position out of bounds.")  # Debug message

func decrement_enemy_count():
	current_enemies -= 1

func _ready():
	add_to_group("EnemySpawner")
	randomize()  # Initialize random number generator
	print("EnemySpawner ready!")  # Debug message
