extends "../pawn.gd"

onready var Grid = get_parent()
export(float, 0, 10) var movement_speed = 1
export(float, 0, 100) var health = 10

signal died

func _ready():
	type = ACTOR
	update_input_direction(Vector2(1, 0))
	$"AnimationPlayer".play("idle")
	$"Pivot/Particles2D/Timer".wait_time = $"Pivot/Particles2D".lifetime
	
func _process(delta):
	if health <= 0:
		print("<slime>: I am le dead.")
		emit_signal("died", self)
		queue_free()
	pass

func act():
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
	var y = randi() % 3 - 1
	var x = randi() % 3 - 1
	return Vector2(x, y)
	
func update_input_direction(direction):
	pass
	
func bump():
	pass
	
func move_to(target_position):
	set_process(false)
	var move_direction = (target_position - position)
	$"AnimationPlayer".play("move")
	$Pivot.position = -move_direction
	$AnimationPlayer.playback_speed = movement_speed
	var move_speed = $AnimationPlayer.current_animation_length / movement_speed
	$Tween.interpolate_property($Pivot, "position", $Pivot.position, Vector2(), move_speed, Tween.TRANS_SINE, Tween.EASE_IN)
	position = target_position
	$Tween.start()
	yield($AnimationPlayer, "animation_finished")
	$"AnimationPlayer".playback_speed = 1
	$"AnimationPlayer".play("idle")
	set_process(true)
	
func take_damage(damage):
	print("<slime>: Taking %2.2f damage!" % damage)
	$AnimationPlayer.play("take_damage")
	health -= damage
	
func emit_blood():
	$Pivot/Particles2D.emitting = true
	$"Pivot/Particles2D/Timer".start()

func shut_off_emit():
	$Pivot/Particles2D.emitting = false
	