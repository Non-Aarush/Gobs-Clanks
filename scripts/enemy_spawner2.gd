extends Node2D

@export var goblin_scene: PackedScene  # Load the goblin scene as a packed scene
@export var barrel_scene: PackedScene  # Load the barrel scene as a packed scene
@onready var stopwatch: Node = get_node("/root/Level2/stopwatch")  # Reference to the stopwatch node
@onready var stopwatch_label = stopwatch.get_node("stopwatchlabel")  # Reference to the stopwatch label
var player = null  # Reference to the player node
var tower = null  # Reference to the tower node

var max_goblins = 8  # Maximum number of active goblins
var current_goblins = 0  # Current number of active goblins
var max_barrels = 4  # Maximum number of active barrels
var current_barrels = 0  # Current number of active barrels
var goblin_spawn_interval = 3.5  # Reduced spawn interval for faster spawning
var barrel_spawn_interval = 5.0  # Longer interval for barrels
var goblin_spawn_timer = goblin_spawn_interval  # Initialize spawn timer
var barrel_spawn_timer = barrel_spawn_interval  # Initialize spawn timer
var initial_delay = 0.5  # Initial delay
var delay_timer = 0.0
var stopwatch_started = false  # Flag to track if stopwatch has started
var spawning_allowed = false  # Flag to control spawning

func _ready():
	add_to_group("EnemySpawner")
	randomize()  # Initialize random number generator

	# Get player and tower references safely
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	else:
		print("Error: No player found in 'player' group.")

	var towers = get_tree().get_nodes_in_group("tower")
	if towers.size() > 0:
		tower = towers[0]
	else:
		print("Error: No tower found in 'tower' group.")

	print("EnemySpawner ready!")  # Debug message

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
			goblin_spawn_timer -= delta
			barrel_spawn_timer -= delta
			
			if goblin_spawn_timer <= 0 and current_goblins < max_goblins:
				spawn_goblin()
				goblin_spawn_timer = goblin_spawn_interval
			
			if barrel_spawn_timer <= 0 and current_barrels < max_barrels:
				spawn_barrel()
				barrel_spawn_timer = barrel_spawn_interval
	else:  # If stopwatch label is not visible
		spawning_allowed = false  # Prevent further spawning
		goblin_spawn_timer = goblin_spawn_interval  # Reset spawn timer
		barrel_spawn_timer = barrel_spawn_interval

func spawn_goblin():
	if player == null:
		print("Error: Player not found.")
		return
	
	var random_distance = randi() % 10 + 1  # Random distance between 1 and 10 tiles
	var random_angle = randf_range(0, PI * 2)  # Random angle
	
	var goblin_position = player.global_position + Vector2(
		cos(random_angle) * random_distance * 16, 
		sin(random_angle) * random_distance * 16
	)
	
	if is_within_bounds(goblin_position):
		var goblin_instance = goblin_scene.instantiate()
		goblin_instance.position = goblin_position
		
		get_tree().get_root().add_child(goblin_instance)
		
		if not goblin_instance.is_in_group("enemies"):
			goblin_instance.add_to_group("enemies")
		
		current_goblins += 1
		print("Goblin spawned at position:", goblin_position)
	else:
		print("Goblin spawn position out of bounds.")

func spawn_barrel():
	if tower == null:
		print("Error: Tower not found.")
		return
	
	var random_distance = randi() % 20 + 10   # Random distance between a farther range (10-30 tiles)
	var random_angle = randf_range(0, PI * 2) 
	
	var barrel_position = tower.global_position + Vector2(
		cos(random_angle) * random_distance * 16,
		sin(random_angle) * random_distance * 16
	)
	
	if is_within_bounds(barrel_position):
		var barrel_instance = barrel_scene.instantiate()
		barrel_instance.position = barrel_position
		
		get_tree().get_root().add_child(barrel_instance)
		
		if not barrel_instance.is_in_group("enemies"):
			barrel_instance.add_to_group("enemies")
		
		current_barrels += 1
	

func is_within_bounds(position):
	var viewport_size = get_viewport().size
	return position.x > 0 and position.x < viewport_size.x and position.y > 0 and position.y < viewport_size.y

func decrement_enemy_count():
	current_goblins -= max(0, current_goblins -1)
	current_barrels -= max(0, current_barrels -1)
