extends Control

func _on_1p_pressed():
	get_tree().change_scene_to_file("res://scenes/main_ai.tscn")

func _on_2p_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_exit_pressed():
	get_tree().quit()
