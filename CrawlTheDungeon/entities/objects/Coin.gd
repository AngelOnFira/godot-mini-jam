extends "../pawn.gd"


func _ready():
	type = OBJECT
	$AnimationPlayer.play("spin")
	
func collect():
	$AnimationPlayer.play("collect")
	yield($AnimationPlayer, "animation_finished")
	queue_free()
