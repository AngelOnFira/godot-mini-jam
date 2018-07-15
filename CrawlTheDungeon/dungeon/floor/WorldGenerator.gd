tool
extends Node
enum TILE {_floor = 0,_wall_left,_wall_right,_wall_up,_wall_down,_wall_center}

var split_density = 0.35

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	generate_dungeon(32,32,4)
	pass

func generate_dungeon(height,width,depth):
	$"Floor".clear()
	var map = []
	var dim = {'x1':0,'x2':width,'y1':0,'y2':height}
	for x in range(width+1):
		var col = []
		col.resize(height+1)
		map.append(col)
	
	rec_vertical(dim,depth,map)
	
	for x in range(0,width):
		for y in range(0,height):
			if not map[x][y] == null:
				$"Floor".set_cell(x,y,map[x][y])
	print('Generation Done')
	
func rec_vertical(dim,depth,map):
	#Base case / creating the size of the room : note to change
	if depth == 0:
		return make_room(dim,map)
		
	#dividing up the rooms
	var slice = dim['x1'] + (dim['x2'] - dim['x1'])/2
	var area1 = {'x1':dim['x1'],'x2':slice,'y1':dim['y1'],'y2':dim['y2']}
	var area2 = {'x1':slice+1,'x2':dim['x2'],'y1':dim['y1'],'y2':dim['y2']}
	var room1 = rec_horizontal(area1,depth-1,map)
	var room2 = rec_horizontal(area2,depth-1,map)

	
	var y_min = max(room1['y1'],room2['y1'])
	var y_max = min(room1['y2'],room2['y2'])

	var y_path = y_min
	if(not y_max-y_min == 0):
		y_path = int(((y_max-y_min)/2)+y_min)
		
	for x in range(room1['x2'],room2['x1']):
		map[x][y_path] = TILE._floor
	
	return room1
	
func rec_horizontal(dim,depth,map):
	if depth == 0:
		return make_room(dim,map)
		
	var slice = dim['y1'] + (dim['y2'] - dim['y1'])/2
	var area1 = {'x1':dim['x1'],'x2':dim['x2'],'y1':dim['y1'],'y2':slice}
	var area2 = {'x1':dim['x1'],'x2':dim['x2'],'y1':slice+1,'y2':dim['y2']}
	var room1 = rec_vertical(area1,depth-1,map)
	var room2 = rec_vertical(area2,depth-1,map)
	
	#make a horizontal line
	
	var x_min = max(room1['x1'],room2['x1'])
	var x_max = min(room1['x2'],room2['x2'])

	var x_path = x_min
	if( not x_max - x_min ==0):
		x_path = int(((x_max-x_min)/2)+x_min)
	
	
	for y in range(room1['y2'],room2['y1']):
		map[x_path][y] = TILE._floor
		
	return room1
	
func make_room(dim,map,density=0.75):
	var height =  int(density*(dim['y2']-dim['y1']))
	var width  =  int(density*(dim['x2']-dim['x1']))
	
	var px     = int(((1-density)/2)*(dim['x2']-dim['x1']) + dim['x1'])
	var py     = int(((1-density)/2)*(dim['y2']-dim['y1']) + dim['y1'])

	var room = {'x1':px,'x2':px+width,'y1':py,'y2':py+height}
	for x in range(room['x1'],room['x2']):
		for y in range(room['y1'],room['y2']):
			map[x][y] = TILE._floor
	return room

		
		