extends Node2D  # Ensure this script extends Node2D

@export var invisibility_duration: float = 7.0  # Duration of invisibility in seconds
@export var cooldown_duration: float = 20.0  # Cooldown duration in seconds

var is_invisible: bool = false
var can_use_ability: bool = true
var original_opacity: float = 1.0  # Store original opacity

# References to nodes
@onready var player_sprite: AnimatedSprite2D = get_parent().get_node("AnimatedSprite2D")
@onready var collision_shape: CollisionShape2D = get_parent().get_node("CollisionShape2D")  # Reference to the CollisionShape2D node

func _ready():
	# Ensure the player_sprite exists and initialize its opacity
	if player_sprite:
		original_opacity = player_sprite.modulate.a
	else:
		print("Error: AnimatedSprite2D node not found. Check your node path.")

	if not collision_shape:
		print("Error: CollisionShape2D node not found. Check your node path.")

func _process(delta):
	if Input.is_action_just_pressed("invis") and can_use_ability:
		activate_invisibility()
		AudioManager.play_sound_effect("invis")

func activate_invisibility():
	if not player_sprite or not collision_shape:
		print("Error: Required nodes not found during activation.")
		return

	is_invisible = true
	can_use_ability = false
	
	# Set opacity to 25%
	player_sprite.modulate.a = 0.25
	
	# Disable the CollisionShape2D node
	collision_shape.disabled = true

	# Start invisibility duration timer using deferred calls
	call_deferred("_deactivate_invisibility_after_timer", invisibility_duration)

func _deactivate_invisibility_after_timer(duration):
	await get_tree().create_timer(duration).timeout
	deactivate_invisibility()

func deactivate_invisibility():
	if not player_sprite or not collision_shape:
		print("Error: Required nodes not found during deactivation.")
		return

	is_invisible = false
	
	# Restore original opacity
	player_sprite.modulate.a = original_opacity
	
	# Enable the CollisionShape2D node
	collision_shape.disabled = false

	# Start cooldown timer using deferred calls
	call_deferred("_reset_ability_after_timer", cooldown_duration)

func _reset_ability_after_timer(duration):
	await get_tree().create_timer(duration).timeout
	_reset_ability()

func _reset_ability():
	can_use_ability = true  # Reset ability so it can be used again
