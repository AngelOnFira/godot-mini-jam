extends "../pawn.gd"

func _ready():
	type = ACTOR
	$"AnimationPlayer".play("idle")

