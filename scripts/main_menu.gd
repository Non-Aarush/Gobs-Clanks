extends Control

func _on_start_pressed():
	# Load the game scene afresh
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_quit_pressed():
	get_tree().quit()
