extends Area2D

@export var speed: float = 400.0  # Speed at which the projectile moves toward the enemy
@export var damage: int = 20  # Damage dealt to enemies
@export var cooldown_duration: float = 10.0  # Cooldown duration in seconds

var target_enemy: Node2D = null  # Stores the nearest enemy
var can_attack: bool = true  # Tracks whether the ability can be used
var is_active: bool = false  # Tracks whether the projectile is currently moving
var cooldown_timer: float = 0.0  # Timer for tracking cooldown

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D  # Reference to the sprite for animations
@onready var collision_shape: CollisionShape2D = $CollisionShape2D  # Reference to collision shape

func _ready():
	hide()  # Start hidden
	collision_shape.set_deferred("disabled", true)  # Disable collision shape at start

func _process(delta):
	if Input.is_action_just_pressed("strike") and can_attack:
		activate_ability()

	if is_active and target_enemy and is_instance_valid(target_enemy):
		move_towards_enemy(delta)

	if not can_attack:
		cooldown_timer -= delta  # Decrease cooldown timer
		if cooldown_timer <= 0:
			can_attack = true  # Ability can be used again

func activate_ability():
	target_enemy = get_nearest_enemy()
	if target_enemy:
		print("Targeting enemy:", target_enemy.name)  # Debug message
		is_active = true
		can_attack = false
		cooldown_timer = cooldown_duration  # Reset cooldown timer
		show()  # Make lightning visible when ability is activated
		animated_sprite.play("travel")  # Play travel animation

func move_towards_enemy(delta):
	var direction = (target_enemy.global_position - global_position).normalized()
	global_position += direction * speed * delta
	
	# Check if we have reached the enemy
	if global_position.distance_to(target_enemy.global_position) < 10:
		strike_enemy()

func strike_enemy():
	print("Reached enemy:", target_enemy.name)  # Debug message
	is_active = false

	animated_sprite.play("strike")  # Play strike animation
	collision_shape.set_deferred("disabled", false)  # Enable collision shape

	# Damage all enemies in collision area after animation
	await animated_sprite.animation_finished
	damage_all_in_area()
	queue_free()  # Remove projectile after striking

func damage_all_in_area():
	var overlapping_bodies = get_overlapping_bodies()
	
	for body in overlapping_bodies:
		if body.is_in_group("enemy") and body.has_method("take_damage"):
			body.take_damage(damage)
			print("Damaged ", body.name)  # Debug message for damage dealt

func get_nearest_enemy():
	var enemies = get_tree().get_nodes_in_group("enemy")
	var nearest_enemy = null
	var shortest_distance = INF
	
	for enemy in enemies:
		if is_instance_valid(enemy):
			var distance = global_position.distance_to(enemy.global_position)
			if distance < shortest_distance:
				shortest_distance = distance
				nearest_enemy = enemy
	
	return nearest_enemy
