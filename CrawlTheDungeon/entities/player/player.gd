extends "../pawn.gd"

onready var Grid = get_parent()
export(float, 0, 10) var movement_speed = 1
var prev_direction = Vector2(1,0)
export(Curve) var damage_roll
export(int, 0, 4) var health = 4

signal dealt_damage
signal died
signal take_damage
signal grab_coin

func _ready():
	type = ACTOR
	update_input_direction(prev_direction)
	$"AnimationPlayer".play("idle")
	$"Pivot/Particles2D/Timer".wait_time = $"Pivot/Particles2D".lifetime
	
func _process(delta):
	var input_direction = get_input_direction()
	if input_direction:
		update_input_direction(input_direction)
		prev_direction = input_direction
		$"WeaponLocations".rotation = prev_direction.angle()
		var target_position = Grid.request_move(self, input_direction)
		if target_position:
			move_to(target_position)
		else:
			bump()
	elif Input.is_action_just_pressed("ui_select"):
		attack()
	if health <= 0:
		die()
	
func die():
	set_process(false)
	print("<player>: I am le dead.")
	emit_signal("died", self)
	$AnimationPlayer.play("die")
	yield($AnimationPlayer, "animation_finished")
	visible = false
	
func attack():
	set_process(false)
	if prev_direction.y > 0:
		$AnimationPlayer.play("attack-down")
	elif prev_direction.y < 0:
		$AnimationPlayer.play("attack-up")
	else:
		$AnimationPlayer.play("attack-right")
	for damaged_loc in Grid.request_attack($"WeaponLocations".get_children(), false):
		var dmg = roll_damage()
		emit_signal("dealt_damage", damaged_loc, dmg)
		print("<Player>: DAMAGE: %s" % dmg)
	
	yield($AnimationPlayer, "animation_finished")
	if prev_direction.y < 0:
		$AnimationPlayer.play("idle-up")
	else:
		$"AnimationPlayer".play("idle")
	set_process(true)
	
func roll_damage():
	# Roll between 0 and 1
	var dam = randf()
	# Value along curve
	return damage_roll.interpolate(dam)
	
	
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
	var move_direction = (target_position - position)
	
	if move_direction.y < 0:
		$"AnimationPlayer".play("walk-up")
	else:
		$"AnimationPlayer".play("walk-right")
	$Pivot.position = -move_direction
	$AnimationPlayer.playback_speed = movement_speed
	var move_speed = $AnimationPlayer.current_animation_length / movement_speed
	$Tween.interpolate_property($Pivot, "position", $Pivot.position, Vector2(), move_speed, Tween.TRANS_LINEAR, Tween.EASE_IN)
	position = target_position
	$Tween.start()
	yield($AnimationPlayer, "animation_finished")
	$"AnimationPlayer".playback_speed = 1
	if prev_direction.y < 0:
		$AnimationPlayer.play("idle-up")
	else:
		$"AnimationPlayer".play("idle")
	set_process(true)
	
func take_damage(dmg):
	var _dmg = int(dmg);
	print("<player>: Taking " + str(_dmg) + " damage!" )
	#$AnimationPlayer.play("take_damage")
	health = max(health-_dmg, 0)
	$AnimationPlayer.play("take_damage")
	$Pivot/Particles2D.emitting = true
	$"Pivot/Particles2D/Timer".start()
	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play("idle")
	emit_signal("take_damage", _dmg)
	
func shut_off_emit():
	$Pivot/Particles2D.emitting = false
	
func pickup(obj):
	obj.visible = false
	if obj.is_in_group("coin"):
		emit_signal("grab_coin")
		print("<player>: Grabed a Coin")
	else:
		$Inventory.add_child(obj)
		print("<player>: Picked up [%s]. Inventory now contains:\n\t%s" % [obj.name, $Inventory.get_children()])
		print("Is in groups " + str(obj.get_groups()))