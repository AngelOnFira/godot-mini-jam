extends "../pawn.gd"


func _ready():
	type = OBJECT
	add_to_group("coin")
	$AnimationPlayer.play("spin")
	
func collect(pawn):
	$AnimationPlayer.play("collect")
	yield($AnimationPlayer, "animation_finished")
	pawn.pickup(self)
	queue_free()
