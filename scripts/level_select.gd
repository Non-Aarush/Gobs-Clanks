extends Control

@onready var level_buttons = [
	$Level1,
	$Level2,
	$Level3,
	$Level4,
	$Level5
]

var last_unlocked_level: int = 1  # Track the last unlocked level

func _ready():
	update_buttons()
	print("LevelSelect ready!")  # Debugging output

func _process(delta):
	# Check if the unlocked level has changed
	if last_unlocked_level != GameManager.level_data.unlocked_levels:
		last_unlocked_level = GameManager.level_data.unlocked_levels
		update_buttons()  # Refresh button states when a level is unlocked

func update_buttons():
	for i in range(level_buttons.size()):
		var btn = level_buttons[i]
		var level_num = i + 1
		
		btn.disabled = !(level_num <= GameManager.level_data.unlocked_levels)  # Enable buttons for unlocked levels

func _on_level_1_pressed() -> void:
	print("Button Level1 pressed!")  # Debugging output
	AudioManager.play_sound_effect("play")
	get_tree().change_scene_to_file("res://scenes/game.tscn")


func _on_level_2_pressed() -> void:
	print("Button Level2 pressed!")  # Debugging output
	AudioManager.play_sound_effect("play")
	get_tree().change_scene_to_file("res://scenes/level2.tscn")


func _on_level_3_pressed() -> void:
	print("Button Level3 pressed!")  # Debugging output
	AudioManager.play_sound_effect("play")
	get_tree().change_scene_to_file("res://scenes/level3.tscn")


func _on_level_4_pressed() -> void:
	print("Button Level4 pressed!")  # Debugging output
	AudioManager.play_sound_effect("play")
	get_tree().change_scene_to_file("res://scenes/level4.tscn")


func _on_level_5_pressed() -> void:
	print("Button Level5 pressed!")  # Debugging output
	AudioManager.play_sound_effect("play")
	get_tree().change_scene_to_file("res://scenes/level5.tscn")
