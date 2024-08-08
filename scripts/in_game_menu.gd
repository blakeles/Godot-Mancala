extends Control

func _ready():
	$'RestartButton'.visible = false
func _on_game_board_game_over():
	$'RestartButton'.visible = true

func _on_restart_button_pressed():
	get_tree().reload_current_scene()
func _on_exit_pressed():
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
