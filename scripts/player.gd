extends CharacterBody2D

@export var speed = 300
@export var acceleration = 50
@export var attack_duration = 0.25 # Total duration of the attack animation in seconds

var idle = true
var attacking = false
var attack_timer = 0.0 # Timer to track the attack animation duration
var facing_direction = "down" # Default facing direction
@export var health = 500
@export var health_max = 500
@export var health_min = 0

# Node paths (Assign in editor)
@onready var animated_sprite = $AnimatedSprite2D
@onready var sword = $sword
@onready var playerhitbox = $playerhitbox  # Assuming you have a Hitbox node
@onready var health_bar = $health_bar  # Assuming you have a HealthBar node

func _physics_process(delta):
	if attacking:
		attack_timer += delta
		if attack_timer >= attack_duration:
			attacking = false
			attack_timer = 0.0
			disable_sword_collisions() # Disable sword collisions after attack
			animated_sprite.play("idle") # Or "run" based on current input
		return  # Prevent movement during attack animation

	var direction = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()

	# Update facing direction
	if direction.y < 0:
		facing_direction = "up"
	elif direction.y > 0:
		facing_direction = "down"
	elif direction.x < 0:
		facing_direction = "left"
	elif direction.x > 0:
		facing_direction = "right"
		
	#Player movements
	velocity.x = move_toward(velocity.x, direction.x * speed, acceleration)
	velocity.y = move_toward(velocity.y, direction.y * speed, acceleration)

	move_and_slide()

	# Check for overlapping areas
	for area in playerhitbox.get_overlapping_areas():
		if area.get_parent().has_node("attack_zone") and area.get_parent().attacking:
			if area.get_parent().attack_timer >= area.get_parent().attack_duration - 0.2:
				take_damage(10)
				area.get_parent().attack_timer = 0.0  # Reset attack timer

	#Animations
	if Input.is_action_just_pressed("attack1") and !attacking:
		attack()

	elif Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left") or Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_down"):
		idle = false
		if !attacking:
			animated_sprite.play("run")
		if Input.is_action_pressed("ui_left"):
			animated_sprite.flip_h = true
		elif Input.is_action_pressed("ui_right"):
			animated_sprite.flip_h = false
	else:
		idle = true
		if !attacking:
			animated_sprite.play("idle")

func attack():
	attacking = true
	attack_timer = 0.0 # Reset the timer
	if facing_direction == "up":
		animated_sprite.play("attack6") 
		$sword/CollisionShape2D.disabled=false # Play the attack_up animation
	elif facing_direction == "down":
		animated_sprite.play("attack4") 
		$sword/CollisionShape2D2.disabled=false # Play the attack_down animation
	elif facing_direction == "left":
		animated_sprite.play("attack1")
		$sword/CollisionShape2D4.disabled=false # Play the attack_left animation
	elif facing_direction == "right":
		animated_sprite.play("attack1")
		$sword/CollisionShape2D3.disabled=false # Play the attack_right animation

func disable_sword_collisions():
	$sword/CollisionShape2D.disabled=true
	$sword/CollisionShape2D2.disabled=true
	$sword/CollisionShape2D3.disabled=true
	$sword/CollisionShape2D4.disabled=true

func take_damage(damage):
	health -= damage
	health_bar.value = health
	
	if health <= 0:
		death()

func death():
	await get_tree().create_timer(0.1).timeout
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	queue_free()

func player():
	pass
