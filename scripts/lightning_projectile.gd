extends Area2D

@export var speed: float = 400.0  # Speed at which the projectile moves toward the enemy
@export var damage: int = 20  # Damage dealt to the enemy
@export var cooldown: float = 10.0  # Cooldown duration in seconds

var target_enemy: Node2D = null  # Stores the nearest enemy
var can_use_ability: bool = true  # Tracks whether the ability can be used
var is_striking: bool = false  # Tracks whether the ability is currently striking

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D  # Reference to the sprite for animations

func _process(delta):
	if Input.is_action_just_pressed("strike") and can_use_ability:
		activate_ability()

	if target_enemy and is_instance_valid(target_enemy) and not is_striking:
		move_towards_enemy(delta)

func activate_ability():
	if not can_use_ability:
		return

	target_enemy = get_nearest_enemy()
	if target_enemy:
		print("Targeting enemy:", target_enemy.name)  # Debug message
		can_use_ability = false
	else:
		print("No enemies found!")  # Debug message

func move_towards_enemy(delta):
	if not target_enemy or !is_instance_valid(target_enemy):
		print("Target enemy is invalid or no longer exists.")  # Debug message
		reset_ability()
		return

	var direction = (target_enemy.global_position - global_position).normalized()
	global_position += direction * speed * delta

	# Check if we have reached the enemy
	if global_position.distance_to(target_enemy.global_position) < 10:
		strike_enemy()

func strike_enemy():
	print("Reached enemy:", target_enemy.name)  # Debug message
	is_striking = true

	# Play strike animation
	animated_sprite.play("strike")

	# Deal damage to the enemy (ensure the enemy has a `take_damage()` method)
	if target_enemy.has_method("take_damage"):
		target_enemy.take_damage(damage)
		print("Dealt", damage, "damage to:", target_enemy.name)  # Debug message

	reset_ability()

func reset_ability():
	print("Resetting ability.")  # Debug message
	target_enemy = null
	is_striking = false

	# Start cooldown timer
	var cooldown_timer = get_tree().create_timer(cooldown)
	await cooldown_timer.timeout
	can_use_ability = true

func get_nearest_enemy():
	var enemies = get_tree().get_nodes_in_group("enemy")
	var nearest_enemy = null
	var shortest_distance = INF

	for enemy in enemies:
		var distance = global_position.distance_to(enemy.global_position)
		if distance < shortest_distance:
			shortest_distance = distance
			nearest_enemy = enemy

	return nearest_enemy
