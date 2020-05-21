extends "../pawn.gd"

onready var Grid = get_parent()
export(float, 0, 10) var movement_speed = 1
export(float, 0, 100) var health = 10
export(Curve) var damage_roll
var coin_scene = preload("res://entities/objects/coin.tscn")
export(float, 0, 100) var damage = 5
signal died
signal dealt_damage

func _ready():
	type = CELL_TYPES.ACTOR
	update_input_direction(Vector2(1, 0))
	$"AnimationPlayer".play("idle")
	$"Pivot/Particles2D/Timer".wait_time = $"Pivot/Particles2D".lifetime
	
func _process(delta):
	if health <= 0:
		die()

func die():
	set_process(false)
	print("<slime>: I am le dead.")
	$ActionTimer.stop()
	$AnimationPlayer.play("die")
	yield($AnimationPlayer, "animation_finished")
	emit_signal("died", self, get_loot())
	queue_free()
func act():
	var vision = Grid.request_surrounding(self)
	var player = []
	var attacking = null
	for pawn in vision:
		if pawn.is_in_group("player"):
			player.append(pawn)
	var input_direction = get_input_direction()
	if len(player) > 0:
		attacking = player[0]
		
	update_input_direction(input_direction)
	if attacking:
		var attack_positions = [attacking]
		for loc in Grid.request_attack(attack_positions):
			var dmg = roll_damage()
			emit_signal("dealt_damage", loc, dmg)
			print("<slime>: DAMAGE: %s" % dmg)
		
		$"AnimationPlayer".play("move")
		yield($AnimationPlayer, "animation_finished")
		$AnimationPlayer.play("idle")
	else:
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
	
func get_loot():
	var roll = randf()
	var loot = []
	if roll < 1:
		loot.append(coin_scene.instance())
	return loot
	
func roll_damage():
	# Roll between 0 and 1
	var dam = randf()
	# Value along curve
	return damage_roll.interpolate(dam)