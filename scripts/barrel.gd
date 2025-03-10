extends CharacterBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var detectionb: Area2D = $detectionb

var speed = 100
var tower: StaticBody2D = null
var reached_tower = false
const EXPLOSION_DISTANCE = 16  # 1 tile distance (16 pixels)


func _physics_process(delta):
	if reached_tower:
		return  # Skip processing if already exploding

	if tower and is_instance_valid(tower):
		var direction = global_position.direction_to(tower.global_position)
		velocity = direction * speed
		move_and_slide()

		# Update animation and direction
		animated_sprite.play("run")
		animated_sprite.flip_h = direction.x < 0

		# Get tower's collision shape position
		var tower_collision_pos = tower.global_position
		if tower.get_child_count() > 0 and tower.get_child(0) is CollisionShape2D:
			tower_collision_pos = tower.get_child(0).global_position

		# Check distance to tower's collision shape
		if global_position.distance_to(tower_collision_pos) <= EXPLOSION_DISTANCE:
			start_explosion()
	else:
		velocity = Vector2.ZERO
		animated_sprite.play("idle")

func start_explosion():
	if reached_tower: 
		return  # Prevent multiple triggers
	reached_tower = true
	velocity = Vector2.ZERO
	animated_sprite.play("explo")
	
	# Calculate animation time
	var sprite_frames = animated_sprite.sprite_frames
	var animation_name = "explo"
	var num_frames = sprite_frames.get_frame_count(animation_name)
	var animation_speed = sprite_frames.get_animation_speed(animation_name)
	
	var animation_time = num_frames / animation_speed
	
	# Queue free after animation time
	await get_tree().create_timer(animation_time).timeout
	queue_free()

func _on_detectionb_body_entered(body):
	if body is StaticBody2D and body.name == "tower":
		tower = body

func _on_detectionb_body_exited(body):
	if body == tower:
		tower = null
		velocity = Vector2.ZERO
