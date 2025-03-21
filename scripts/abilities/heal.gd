extends Node2D  # Ensure this script extends Node2D

@export var healing_amount: int = 28  # Amount of health to heal per second
@export var healing_duration: float = 4.0  # Duration of the healing aura in seconds
@export var cooldown_duration: float = 30.0  # Cooldown duration in seconds
@export var glow_color: Color = Color(0, 1, 0, 0.5)  # Green color for the glow effect

var can_use_ability: bool = true  # Track if the ability can be used

# References to nodes
@onready var player_sprite: AnimatedSprite2D = get_parent().get_node("AnimatedSprite2D")
@onready var player: CharacterBody2D = get_parent()  # Reference to the parent player node
@onready var health_bar: ProgressBar = get_parent().get_node("health_bar")  # Reference to the health bar node

func _ready():
	# Ensure references are valid
	if not player_sprite:
		print("Error: AnimatedSprite2D node not found.")
	if not player:
		print("Error: Player node not found.")
	if not health_bar:
		print("Error: HealthBar node not found.")

func _process(delta):
	# Check for input to activate the healing aura
	if Input.is_action_just_pressed("heal") and can_use_ability:
		activate_healing_aura()

func activate_healing_aura():
	if not can_use_ability or not player or not health_bar:
		return
	
	can_use_ability = false
	player_sprite.modulate = glow_color  # Change color to indicate healing aura
	
	# Disable player movement
	player.set_process_input(false)  # Disable input processing for movement
	
	# Start healing over time
	var elapsed_time: float = 0.0
	
	while elapsed_time < healing_duration:
		await get_tree().create_timer(0.5).timeout  # Wait for one second
		
		heal_player(healing_amount)  # Heal the player by the specified amount
		elapsed_time += 0.5  # Increment elapsed time by one second

	deactivate_healing_aura()  # Deactivate the aura after healing

func heal_player(amount: int):
	# Directly update player's health variable
	player.health += amount
	if player.health > player.health_max:
		player.health = player.health_max  # Cap health at maximum
	
	# Update health bar value immediately
	health_bar.value = player.health

func deactivate_healing_aura():
	player_sprite.modulate = Color(1, 1, 1, 1)  # Reset color back to original
	player.set_process_input(true)  # Re-enable input processing for movement
	
	# Start cooldown timer
	var cooldown_timer = get_tree().create_timer(cooldown_duration)
	
	await cooldown_timer.timeout
	
	can_use_ability = true  # Ability can be used again
