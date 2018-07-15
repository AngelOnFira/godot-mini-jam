extends Control


func _on_StartGame_pressed():
	get_tree().change_scene("res://dungeon/floor/Floor1.tscn")


func _on_ExitGame_pressed():
	get_tree().quit()