extends Area2D  # Use Area2D as the base class

@export var speed: float = 600.0  # Speed at which the lightning projectile moves
@export var damage: int = 3 # Damage dealt to the enemy
@export var cooldown: float = 5.0  # Cooldown duration in seconds
@export var strike_radius: float = 50.0  # Radius around the target for damage application

# Use preload for reliable loading of PackedScene
var lightning_projectile_scene: PackedScene = preload("res://scenes/lightning_projectile.tscn")

var target_enemy: Node2D = null  # Stores the nearest enemy
var can_use_ability: bool = true  # Tracks whether the ability can be used
var is_striking: bool = false  # Tracks whether the ability is currently striking
var active_projectile: Node2D = null  # Stores reference to the active projectile

# Flag to track whether input should be ignored
var is_ability_active: bool = false
var input_disabled: bool = false  # Flag to track input cooldown

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D  # Reference to the sprite for animations

func _ready():
	animated_sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))  # Connect signal to handle animation finish
	hide()  # Hide projectile initially

func _process(delta):
	if Input.is_action_just_pressed("strike") and can_use_ability and not is_ability_active and not input_disabled:
		activate_ability()
		AudioManager.play_sound_effect("lightning")

	if active_projectile and is_instance_valid(active_projectile) and target_enemy and is_instance_valid(target_enemy):
		move_projectile_towards_enemy(delta)

func activate_ability():
	if not can_use_ability or is_ability_active or input_disabled or active_projectile:
		return

	input_disabled = true  # Disable input immediately upon activation
	can_use_ability = false  # Disable ability usage
	is_ability_active = true  # Set flag to true to ignore input during cooldown

	if lightning_projectile_scene == null:
		print("Error: lightning_projectile_scene is null! Ensure it is assigned correctly.")
		return

	target_enemy = get_nearest_enemy()
	if target_enemy:
		print("Targeting enemy:", target_enemy.name)  # Debug message
		
		# Spawn a new instance of LightningProjectile
		active_projectile = lightning_projectile_scene.instantiate()
		get_parent().add_child(active_projectile)  # Add it to the player's parent node (the scene)
		
		# Set position of new projectile to player's position
		active_projectile.global_position = global_position
		
		active_projectile.show()  # Ensure new projectile is visible
		
		# Initialize the new projectile's target enemy
		active_projectile.target_enemy = target_enemy
		
		active_projectile.connect("tree_exited", Callable(self, "_on_projectile_despawned"))  # Ensure cleanup on despawn
		active_projectile.connect("area_entered", Callable(self, "_on_projectile_area_entered"))  # Detect collision with enemy
		
		await start_cooldown()  # Wait for cooldown period before re-enabling input
	else:
		print("No enemies found!")  # Debug message

func move_projectile_towards_enemy(delta):
	if not active_projectile or not target_enemy:
		return

	var direction = (target_enemy.global_position - active_projectile.global_position).normalized()
	active_projectile.global_position += direction * speed * delta

	if active_projectile.global_position.distance_to(target_enemy.global_position) < strike_radius:
		strike_enemy()

func strike_enemy():
	print("Striking enemy:", target_enemy.name)  # Debug message
	is_striking = true

	if active_projectile and active_projectile.has_node("AnimatedSprite2D"):
		var projectile_sprite = active_projectile.get_node("AnimatedSprite2D")
		projectile_sprite.play("strike")  # Change animation to "strike"

	var enemy = target_enemy
	if enemy is CollisionShape2D:
		enemy = enemy.get_parent()

	if enemy and enemy.has_method("take_damage"):
		enemy.take_damage(damage)
		print("Dealt", damage, "damage to:", enemy.name)  # Debug message
	
	# Destroy the projectile after striking
	if active_projectile:
		await get_tree().create_timer(0.5).timeout  # Small delay before despawning
		if active_projectile:  # Ensure the projectile still exists before freeing
			active_projectile.queue_free()
			active_projectile = null

func _on_projectile_area_entered(area):
	var enemy = area
	if area is CollisionShape2D:
		enemy = area.get_parent()
		if not enemy:
			return
	
	if enemy and enemy.is_in_group("enemies") and enemy.has_method("take_damage"):
		enemy.take_damage(damage)
		print("Dealt", damage, "damage to:", enemy.name)
		strike_enemy()

func _on_animation_finished():
	print("Animation finished, despawning projectile.")  # Debug message
	hide() # Hide projectile instead of removing it from the scene
	if active_projectile:
		active_projectile.queue_free()
		active_projectile = null  # Ensure projectile is reset

func _on_projectile_despawned():
	active_projectile = null  # Clear reference when projectile is removed from scene

# Start cooldown and reset flags after cooldown period using await
func start_cooldown():
	print("Starting cooldown...")  # Debug message
	await get_tree().create_timer(cooldown).timeout  # Wait for cooldown duration to finish
	
	can_use_ability = true  # Reset ability flag after cooldown
	is_ability_active = false  # Reset flag to allow input again
	input_disabled = false  # Re-enable input after cooldown
	
	print("Cooldown finished, input enabled.")  # Debug message

func get_nearest_enemy():
	var enemies = get_tree().get_nodes_in_group("enemies")
	var nearest_enemy = null
	var shortest_distance = INF

	for enemy in enemies:
		var distance = global_position.distance_to(enemy.global_position)
		if distance < shortest_distance:
			shortest_distance = distance
			nearest_enemy = enemy

	return nearest_enemy
