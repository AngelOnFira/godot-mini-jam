extends "../pawn.gd"


func _ready():
	type = CELL_TYPES.OBJECT
	add_to_group("coin")
	add_to_group("item")
	$AnimationPlayer.play("spin")
	
func collect(pawn):
	$AnimationPlayer.play("collect")
	yield($AnimationPlayer, "animation_finished")
	pawn.pickup(self)
	queue_free()
