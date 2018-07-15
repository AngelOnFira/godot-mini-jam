tool
extends Node
enum TILE {_floor = 0,_wall_left,_wall_right,_wall_up,_wall_down,_wall_center}

const room_density  = 0.75
const split_density = 0.35
const min_room_area = 25

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	generate_dungeon(32,32,3)
	pass

func generate_dungeon(height,width,depth):
	$"Floor".clear()
	var map = []
	var dim = {'x1':0,'x2':width,'y1':0,'y2':height}
	for x in range(width+1):
		var col = []
		col.resize(height+1)
		map.append(col)
	
	recursive_gen(dim,map)
	
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
	var p1 = int(split_density*(dim['x2']-dim['x1']))
	var p2 = int((1-split_density)*(dim['x2']-dim['x1']))
	#var slice = (randi()%(p2-p1)) + dim['x1']
	var slice = dim['x1'] + (dim['x2'] - dim['x1'])/2
	var area1 = {'x1':dim['x1'],'x2':slice,'y1':dim['y1'],'y2':dim['y2']}
	var area2 = {'x1':slice+1,'x2':dim['x2'],'y1':dim['y1'],'y2':dim['y2']}
	
	var room1 = rec_horizontal(area1,depth-1,map)
	var room2 = rec_vertical(area2,depth-1,map)

	
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
	
	var p1 = int(split_density*(dim['y2']-dim['y1']))
	var p2 = int((1-split_density)*(dim['y2']-dim['y1']))
	#var slice = (randi()%(p2-p1)) + dim['y1']	
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
	
func area(dim):
	return abs((dim['x2']-dim['x1'])*(dim['y2']-dim['y1']))
	

func recursive_gen(dim,map):
	var areas = []
	var rooms = []
	var cleaned_rooms = []
	
	#base case, this room does not have enough to make a room
	if(area(dim)*pow(room_density,2) < min_room_area):
		return null
	
	#split the room vertically, or horizontally
	if(wrapi(randi(),0,2) == 0):
		areas = splitv2(dim)
	else :
		areas = splith2(dim)
	
	
	for room in areas:
		rooms.append(recursive_gen(room,map))
	
	if rooms[0] == null && rooms[1] == null:
		rooms = [make_room(dim,map)]
		
	print(rooms)
	
	for room in rooms:
		if not room == null:
			cleaned_rooms.append(room)
	return cleaned_rooms

func splitv(dim):
	var slice = dim['x1'] + (dim['x2'] - dim['x1'])/2
	var area1 = {'x1':dim['x1'],'x2':slice,'y1':dim['y1'],'y2':dim['y2']}
	var area2 = {'x1':slice+1,'x2':dim['x2'],'y1':dim['y1'],'y2':dim['y2']}
	
	return [area1,area2]

func splitv2(dim):
	var p1 = int(split_density*(dim['x2']-dim['x1']))
	var p2 = int((1-split_density)*(dim['x2']-dim['x1']))
	var slice = (wrapi(randi(),0,(p2-p1))) + dim['x1']
	
	var area1 = {'x1':dim['x1'],'x2':slice,'y1':dim['y1'],'y2':dim['y2']}
	var area2 = {'x1':slice+1,'x2':dim['x2'],'y1':dim['y1'],'y2':dim['y2']}
	
	return [area1,area2]

func splith(dim):
	var slice = dim['y1'] + (dim['y2'] - dim['y1'])/2
	
	var area1 = {'x1':dim['x1'],'x2':dim['x2'],'y1':dim['y1'],'y2':slice}
	var area2 = {'x1':dim['x1'],'x2':dim['x2'],'y1':slice+1,'y2':dim['y2']}
	
	return [area1,area2]

func splith2(dim):
	var p1 = int(split_density*(dim['y2']-dim['y1']))
	var p2 = int((1-split_density)*(dim['y2']-dim['y1']))
	var slice = (wrapi(randi(),0,(p2-p1))) + dim['y1']
	
	var area1 = {'x1':dim['x1'],'x2':dim['x2'],'y1':dim['y1'],'y2':slice}
	var area2 = {'x1':dim['x1'],'x2':dim['x2'],'y1':slice+1,'y2':dim['y2']}
	
	return [area1,area2]
	
	
func make_room(dim,map):
	var height =  int(room_density*(dim['y2']-dim['y1']))
	var width  =  int(room_density*(dim['x2']-dim['x1']))
	
	var px     = int(((1-room_density)/2)*(dim['x2']-dim['x1']) + dim['x1'])
	var py     = int(((1-room_density)/2)*(dim['y2']-dim['y1']) + dim['y1'])

	var room = {'x1':px,'x2':px+width,'y1':py,'y2':py+height}
	for x in range(room['x1'],room['x2']):
		for y in range(room['y1'],room['y2']):
			map[x][y] = TILE._floor
	
	print(room)
	return room
	

		
		