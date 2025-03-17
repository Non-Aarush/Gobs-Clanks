extends StaticBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var stopwatch: Node = get_node("/root/Game/stopwatch")
@onready var health_bar: ProgressBar = $health_bar  # Assuming this is your healthbar progress bar
@export var health = 5000
var health_max = 5000
var health_min = 0

func _process(delta):
	if stopwatch and stopwatch.time_left <= 1 and stopwatch.is_running == true:
		animated_sprite.animation = "idle"
		remove_child(health_bar)  # Remove the healthbar progress bar from the scene tree

func take_damage(amount):
	health = clamp(health - amount, health_min, health_max)
	health_bar.value = health  # Update the healthbar value
	print("Tower health: ", health)  # For debugging
	if health <= 0:
		queue_free()  # Or add destruction logic

func _on_tower_area_area_entered(area: Area2D):
	if area.get_parent().has_method("player"):
		stopwatch.start()
		if not has_node("health_bar"):  # Check if health_bar node exists
			health_bar = ProgressBar.new()  # Create a new ProgressBar if it doesn't exist
			health_bar.name = "health_bar"  # Set its name
			health_bar.max_value = health_max  # Set its max value
			health_bar.value = health  # Set its initial value
			add_child(health_bar)  # Add it as a child of the tower
		health_bar.visible = true  # Show the healthbar progress bar when the stopwatch starts

func tower():
	pass
