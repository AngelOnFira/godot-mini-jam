extends "../pawn.gd"

onready var Grid = get_parent()

func _ready():
	update_input_direction(Vector2(1, 0))
	$"AnimationPlayer".play("idle")
	
func _process(delta):
	var input_direction = get_input_direction()
	if not input_direction:
		return
	update_input_direction(input_direction)
	var target_position = Grid.request_move(self, input_direction)
	if target_position:
		move_to(target_position)
	else:
		bump()
	
func get_input_direction():
	var y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	var x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	return Vector2(x, y)
	
func update_input_direction(direction):
	match direction:
		Vector2(-1, 0):
			$"Pivot".scale.x = -1
		Vector2(1, 0):
			$"Pivot".scale.x = 1
	
func bump():
	pass
	
func move_to(target_position):
	set_process(false)
	$"AnimationPlayer".play("walk-right")
	var move_direction = (target_position - position).normalized()
	$Tween.interpolate_property($Pivot, "position", -move_direction * 16, Vector2(), $AnimationPlayer.current_animation_length, Tween.TRANS_LINEAR, Tween.EASE_IN)
	position = target_position
	$Tween.start()
	yield($AnimationPlayer, "animation_finished")
	$"AnimationPlayer".play("idle")
	set_process(true)