extends Contol

var scene_path_to_load

func _ready():
	$"Menu/CenterRow/Buttons/NewGame".grab_focus()
	for button in $"Menu/CenterRow/Buttons".get_children():
		button.connect("pressed", self, "_on_Button_pressed", [button.scene_to_load])
		


func _on_FadeIn_fade_finished():
	$FadeIn.hide()
	
