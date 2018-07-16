extends TileMap

enum CELL_TYPES { EMPTY = -1, ACTOR=143 OBSTACLE, OBJECT }

func _ready():
	for child in get_children():
		set_cellv(world_to_map(child.position), child.type)
		
func get_cell_pawn(coordinates):
	for node in get_children():
		if world_to_map(node.position) == coordinates:
			return node

func request_move(pawn, direction):
	var cell_start = world_to_map(pawn.position)
	var cell_target = cell_start + direction
	
	var cell_target_type = get_cellv(cell_target)
	match cell_target_type:
		EMPTY:
			print('%s moved to %s' % [pawn.name, cell_target])
			return update_pawn_position(pawn, cell_start, cell_target)
		OBJECT:
			if !pawn.is_in_group("player"): return
			var object_pawn = get_cell_pawn(cell_target)
			if object_pawn.is_in_group("item"):
				object_pawn.collect(pawn)
			return update_pawn_position(pawn, cell_start, cell_target)
		ACTOR:
			var pawn_name = get_cell_pawn(cell_target).name
			
func request_attack(positions, global=true):
	var successful_hits = []

	for attack_location in positions:
		var loc = attack_location.position if global else attack_location.to_global(attack_location.position)
		var cell = world_to_map(loc)
		print(cell)
		var cell_target_type = get_cellv(cell)
		match cell_target_type:
			ACTOR:
				successful_hits.append(map_to_world(cell))
	return successful_hits
		
func update_pawn_position(pawn, cell_start, cell_target):
	set_cellv(cell_target, pawn.type)
	set_cellv(cell_start, EMPTY)
	return map_to_world(cell_target) + cell_size/2

func _on_died(pawn, loot=[]):
	var cell = world_to_map(pawn.position)
	set_cellv(cell, EMPTY)
	if len(loot) > 0: 
		print(loot[0].name)
		set_cellv(cell, OBJECT)
	for l in loot:
		l.position = pawn.position
		add_child(l)

func _on_dealt_damage(location, damage):
	location.x += 8
	location.y += 8
	var cell = world_to_map(location)
	var pawn = get_cell_pawn(cell)
	pawn.take_damage(damage)
	
func request_surrounding(pawn):
	var cell = world_to_map(pawn.position)
	var pawns = []
	for row in [-1, 0, 1]:
		for col in [-1, 0, 1]:
			var target_cell = Vector2(cell.x+col, cell.y+row)
			var target_pawn = get_cell_pawn(target_cell)
			if target_pawn:
				pawns.append(target_pawn)
	return pawns
