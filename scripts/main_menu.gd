extends Control

func _on_start_pressed():
	AudioManager.play_sound_effect("play")
	# Load the game scene afresh
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func _on_quit_pressed():
	AudioManager.play_sound_effect("quit")
	get_tree().quit()
