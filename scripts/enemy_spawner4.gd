extends Node2D

@export var goblin_scene: PackedScene
@export var barrel_scene: PackedScene
@onready var stopwatch: Node = get_node("/root/Level4/stopwatch")
@onready var stopwatch_label = stopwatch.get_node("stopwatchlabel")
var player = null
var tower = null

var max_goblins = 20
var current_goblins = 0
var max_barrels = 8
var current_barrels = 0
var goblin_spawn_interval = 3.5
var barrel_spawn_interval = 5.0
var goblin_spawn_timer = goblin_spawn_interval
var barrel_spawn_timer = barrel_spawn_interval
var initial_delay = 0.5
var delay_timer = 0.0
var stopwatch_started = false
var spawning_allowed = false

func _ready():
	add_to_group("EnemySpawner")
	randomize()

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

	print("EnemySpawner ready!")

func _process(delta):
	if stopwatch_label.visible:
		if not stopwatch_started:
			stopwatch_started = true
			delay_timer = 0.0
			spawning_allowed = false
		
		delay_timer += delta
		
		if delay_timer >= initial_delay:
			spawning_allowed = true
		
		if spawning_allowed:
			goblin_spawn_timer -= delta
			barrel_spawn_timer -= delta
			
			if goblin_spawn_timer <= 0 and current_goblins < max_goblins:
				spawn_goblin()
				goblin_spawn_timer = goblin_spawn_interval
			
			if barrel_spawn_timer <= 0 and current_barrels < max_barrels:
				spawn_barrel()
				barrel_spawn_timer = barrel_spawn_interval
	else:
		spawning_allowed = false
		goblin_spawn_timer = goblin_spawn_interval
		barrel_spawn_timer = barrel_spawn_interval

func spawn_goblin():
	if player == null:
		print("Error: Player not found.")
		return
	
	var random_distance = randi() % 10 + 1
	var random_angle = randf_range(0, PI * 2)
	
	var goblin_position = player.global_position + Vector2(
		cos(random_angle) * random_distance * 16, 
		sin(random_angle) * random_distance * 16
	)
	
	var goblin_instance = goblin_scene.instantiate()
	goblin_instance.position = goblin_position
	get_tree().get_root().add_child(goblin_instance)
	
	if not goblin_instance.is_in_group("enemies"):
		goblin_instance.add_to_group("enemies")
	
	current_goblins += 1
	print("Goblin spawned at position:", goblin_position)

func spawn_barrel():
	if tower == null:
		print("Error: Tower not found.")
		return
	
	var random_distance = randi() % 20 + 10
	var random_angle = randf_range(0, PI * 2)
	
	var barrel_position = tower.global_position + Vector2(
		cos(random_angle) * random_distance * 16,
		sin(random_angle) * random_distance * 16
	)
	
	var barrel_instance = barrel_scene.instantiate()
	barrel_instance.position = barrel_position
	get_tree().get_root().add_child(barrel_instance)
	
	if not barrel_instance.is_in_group("enemies"):
		barrel_instance.add_to_group("enemies")
	
	current_barrels += 1

func decrement_enemy_count():
	current_goblins = max(0, current_goblins - 1)
	current_barrels = max(0, current_barrels - 1)
