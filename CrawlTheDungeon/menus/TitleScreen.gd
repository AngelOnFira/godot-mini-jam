extends Control

var scene_path_to_load

func _ready():
	$"Menu/CenterRow/Buttons/StartGame".grab_focus()
	for button in $"Menu/CenterRow/Buttons".get_children():
		print(button.scene_to_load)
		button.connect("pressed", self, "_on_Button_pressed", [button.scene_to_load])
		
func _on_Button_pressed(scene_to_load):
	$FadeIn.show()
	$FadeIn.fade_in()
	scene_path_to_load = scene_to_load

func _on_FadeIn_fade_finished():
	$FadeIn.hide()
	get_tree().change_scene(scene_path_to_load)
