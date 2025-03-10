extends CharacterBody2D

# Exported variables
@export var run_speed = 125
@export var attack_duration = 0.5  # Duration of the attack animation
@export var attack_interval = 0.5  # Interval between attacks
@export var health = 100 # Enemy's initial health
var health_max = 100
var health_min = 0
@export var knockback_speed = 200  # Speed of the knockback

# Node paths (Assign in editor)
@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_zone = $attack_zone

@onready var hitbox= $hitbox
@onready var health_bar = $health_bar  # Assuming you have a HealthBar node

# Internal variables
var player = null
var attacking = false
var attack_timer = 0.0
var attack_cooldown = attack_interval  # Initialize cooldown to interval
var player_in_detection_zone = false
var player_in_attack_zone = false
var knockback_applied = false  # Flag to prevent continuous knockback

func _physics_process(delta):
	if not knockback_applied:
		if player_in_detection_zone and player and player.has_method("player") and not player_in_attack_zone:
			var direction = (player.position - position).normalized()
			
			# Prevent direct overlap by slowing down when close
			if position.distance_to(player.position) < 20:  # Adjust this distance as needed
				velocity = direction * run_speed / 2  # Slow down when close to player
			else:
				velocity = direction * run_speed
			
			animated_sprite.play("run")
			
			# Flip sprite based on direction
			if player.position.x < position.x:
				animated_sprite.flip_h = true
			else:
				animated_sprite.flip_h = false
		elif player_in_attack_zone and player and player.has_method("player"):
			if not attacking:
				attacking = true
				attack_player()
				attack_timer = 0.0
			else:
				attack_timer += delta
				if attack_timer >= attack_duration:
					attacking = false
					attack_timer = 0.0
					attack_cooldown -= delta
					if attack_cooldown <= 0:
						attacking = true
						attack_cooldown = attack_interval
						attack_player()
		else:
			animated_sprite.play("idle")
			velocity = Vector2.ZERO  # Stop movement when not chasing or attacking
	
	move_and_slide()

func _on_detection_body_entered(body):
	if body.has_method("player"):
		player = body
		player_in_detection_zone = true

func _on_detection_body_exited(body):
	if body == player:
		player = null
		player_in_detection_zone = false

func _on_attack_zone_body_entered(body):
	if body == player and body.has_method("player"):
		player_in_attack_zone = true

func _on_attack_zone_body_exited(body):
	if body == player:
		player_in_attack_zone = false
		attacking = false
		attack_cooldown = attack_interval  # Reset cooldown when exiting

func attack_player():
	if player and player.has_method("player") and player.position.x < position.x:  # Player is on the left
		animated_sprite.play("attack_side")
		animated_sprite.flip_h = true
	elif player and player.has_method("player") and player.position.x > position.x:  # Player is on the right
		animated_sprite.play("attack_side")
		animated_sprite.flip_h = false

func _on_hitbox_area_entered(area: Area2D):
	if area.has_method("sword"):  # Check if the entering area is in the "Sword" group
		take_damage(25)  # Adjusted damage to match the expected number of hits

func take_damage(damage):
	health -= damage
	health_bar.value = health
	
	# Apply knockback
	if player and player.has_method("player"):
		var knockback_direction = (position - player.position).normalized()
		velocity = knockback_direction * knockback_speed
		knockback_applied = true
		
		# Flash red with 25% opacity for 0.2 seconds
		animated_sprite.modulate = Color(1, 0, 0, 0.25)  # Red with 25% opacity
		await get_tree().create_timer(0.2).timeout
		animated_sprite.modulate = Color(1, 1, 1, 1)  # Reset to full opacity white
		knockback_applied = false
		velocity = Vector2.ZERO
	
	if health <= 0:
		death()

func death():
	queue_free()
	get_tree().get_nodes_in_group("EnemySpawner")[0].decrement_enemy_count()

func get_attack_timer():
	return attack_timer

func get_attack_duration():
	return attack_duration
func enemy():
	pass
