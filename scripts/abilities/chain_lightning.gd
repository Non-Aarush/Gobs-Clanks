extends Area2D  # Ensure this script extends Area2D

@export var damage: int = 20  # Damage dealt to enemies
@export var cooldown_duration: float = 10.0  # Cooldown duration in seconds
@export var spawn_offset: float = 128.0  # Distance to spawn above the enemy
@export var active_duration: float = 4.0  # Duration lightning stays active after striking

var target_enemy: Node2D = null  # Stores the nearest enemy
var can_attack: bool = true  # Tracks whether the ability can be used
var is_active: bool = false  # Tracks whether the ability is currently active

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D  # Reference to the sprite for animations
@onready var collision_shape: CollisionShape2D = $CollisionShape2D  # Reference to collision shape

func _ready():
	hide()  # Start hidden
	animated_sprite.visible = false  # Ensure `AnimatedSprite2D` starts invisible
	collision_shape.set_deferred("disabled", true)  # Disable collision shape at start

func _process(delta):
	if Input.is_action_just_pressed("strike") and can_attack:
		activate_ability()

func activate_ability():
	target_enemy = get_nearest_enemy()
	if target_enemy:
		print("Targeting enemy:", target_enemy.name)  # Debug message
		can_attack = false
		is_active = true
		global_position = target_enemy.global_position + Vector2(0, -spawn_offset)  # Position above enemy
		
		show()  # Make lightning visible when ability is activated
		animated_sprite.visible = true  # Show `AnimatedSprite2D`
		animated_sprite.play("strike")  # Play strike animation
		
		collision_shape.set_deferred("disabled", false)  # Enable collision shape for overlapping detection
		
		damage_all_in_area()  # Immediately apply damage to all overlapping enemies
		
		# Wait for active duration before hiding the projectile
		await get_tree().create_timer(active_duration).timeout  
		deactivate_ability()

func deactivate_ability():
	print("Deactivating ability.")  # Debug message
	hide()  # Hide the lightning projectile
	animated_sprite.visible = false  # Make `AnimatedSprite2D` invisible again
	collision_shape.set_deferred("disabled", true)  # Disable collision shape again
	
	is_active = false
	yield(get_tree().create_timer(cooldown_duration), "timeout")  # Wait for cooldown duration before allowing reuse
	can_attack = true

func damage_all_in_area():
	var overlapping_bodies = get_overlapping_bodies()  # Get all bodies overlapping the Area2D
	
	for body in overlapping_bodies:
		if body.is_in_group("enemies") and body.has_method("take_damage"):
			body.take_damage(damage)
			print("Damaged ", body.name)  # Debug message for damage dealt

func get_nearest_enemy():
	var enemies = get_tree().get_nodes_in_group("enemies")
	var nearest_enemy = null
	var shortest_distance = INF
	
	for enemy in enemies:
		if is_instance_valid(enemy):
			var distance = global_position.distance_to(enemy.global_position)
			if distance < shortest_distance:
				shortest_distance = distance
				nearest_enemy = enemy
	
	return nearest_enemy
