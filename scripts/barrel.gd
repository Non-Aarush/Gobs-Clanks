extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detectionb: Area2D = $detectionb
@onready var hitbox = $hitboxb  # Assuming you have a hitbox node
@onready var explosion_area = $explosion_area  # Assuming you have an ExplosionArea node

var speed = 100
var tower: StaticBody2D = null
var reached_tower = false
var is_explosion_active = false  # Flag to track if explosion animation is active

func _physics_process(delta):
	if reached_tower:
		return

	if tower and is_instance_valid(tower):
		var direction = global_position.direction_to(tower.global_position)
		velocity = direction * speed
		move_and_slide()

		# Check for collisions after movement
		for i in get_slide_collision_count():
			var collision = get_slide_collision(i)
			if collision.get_collider() == tower:
				start_explosion()
				return

		animated_sprite.play("run")
		animated_sprite.flip_h = direction.x < 0
	else:
		velocity = Vector2.ZERO
		animated_sprite.play("idle")

func start_explosion():
	reached_tower = true
	velocity = Vector2.ZERO
	animated_sprite.play("explo")
	AudioManager.play_sound_effect("explo")
	# Damage the tower only if it's in contact
	if is_touching_tower():
		if is_instance_valid(tower) and tower.has_method("take_damage"):
			tower.take_damage(1000)
	
	is_explosion_active = true  # Set flag to true
	
	# Enable explosion area for detecting nearby players
	explosion_area.monitoring = true
	
	# Delay applying damage and knockback to players by 0.2 seconds
	await get_tree().create_timer(0.2).timeout
	
	# Check for players in explosion area after delay
	for area in explosion_area.get_overlapping_areas():
		if area.name == "playerhitbox":
			var player = area.get_parent()  # Get the player node
			if player.has_method("take_damage"):  # Ensure player has take_damage method
				player.take_damage(50,)
				apply_knockback(player)
	
	var sprite_frames = animated_sprite.sprite_frames
	var animation_time = sprite_frames.get_frame_count("explo") / sprite_frames.get_animation_speed("explo")
	
	await get_tree().create_timer(animation_time - 0.2).timeout  # Adjust animation time to account for delay
	is_explosion_active = false  # Set flag to false after animation
	explosion_area.monitoring = false  # Disable monitoring after animation
	queue_free()

func is_touching_tower():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider() == tower:
			return true
	return false

func apply_knockback(player: CharacterBody2D):
	var knockback_direction = (player.global_position - global_position).normalized()
	player.velocity = knockback_direction * 590  # Adjust knockback speed as needed

func _on_detectionb_body_entered(body):
	if body is StaticBody2D and body.name == "tower":
		tower = body

func _on_detectionb_body_exited(body):
	if body == tower:
		tower = null
		velocity = Vector2.ZERO

func _on_hitboxb_area_entered(area: Area2D):
	if area.is_in_group("sword"):  # Check if the entering area is in the "sword" group
		start_explosion()
		GameManager.add_coins(4)

func _on_explosion_area_area_entered(area: Area2D):
	if area.name == "playerhitbox" and is_explosion_active:  # Check if the entering area is named "playerhitbox" and explosion is active
		var player = area.get_parent()  # Get the player node
		if player.has_method("take_damage"):  # Ensure player has take_damage method
			player.take_damage(70)

func _on_explosion_area_area_exited(area: Area2D):
	if area.name == "playerhitbox":
		pass  # You can add logic here if needed
func enemy():
	pass
