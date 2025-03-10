

extends StaticBody2D

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D  # Assuming you have an AnimatedSprite2D node
@onready var collision_shape: CollisionShape2D = $CollisionShape2D  # Assuming you have a CollisionShape2D node
@onready var stopwatch: Node = get_node("/root/Game/stopwatch")  # Reference to the stopwatch node

func _process(delta):
	if stopwatch and stopwatch.time_left <= 1 and stopwatch.is_running == true:
		animated_sprite.animation = "idle"  # Switch to the "idle" animation

func _on_tower_area_area_entered(area: Area2D):
	if area.get_parent().has_method("player"):  # Check if the parent has the 'player' method
		stopwatch.start()  # Start the stopwatch
 # Start the stopwatch

func tower():
	pass
