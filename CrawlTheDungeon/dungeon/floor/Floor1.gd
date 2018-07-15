extends Node

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	pass

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass


func _on_player_dealt_damage(location, damage):
	location.x += 8
	location.y += 8
	print("<world>: Attack at %s" % location)
	for entity in $Map.get_children():
		if entity.is_in_group("enemy"):
			print("<world>: Found enemy at %s" % entity.position) 
			if entity.position == location:
				entity.take_damage(damage)
	