tool
extends Node
enum TILE {_floor = 0,_wall_left,_wall_right,_wall_up,_wall_down,_wall_center}
enum SPLIT_TYPE {HORIZONTAL,VERTICAL}

const room_density  = 0.75
const split_density = 0.35
const min_room_area = 25

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	generate_dungeon(16,16)
	pass

func generate_dungeon(height,width):
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
	
func area(dim):
	return abs((dim['x2']-dim['x1'])*(dim['y2']-dim['y1']))
	

func recursive_gen(dim,map):
	var areas = []
	var rooms = []
	var seperated = []
	var cleaned_rooms = []
	var split_types = [SPLIT_TYPE.HORIZONTAL,SPLIT_TYPE.VERTICAL]
	
	#base case, this room does not have enough to make a room
	if(area(dim)*pow(room_density,2) < min_room_area):
		return []
	
	#split the room vertically, or horizontally
	var split = split_types[randi()%len(split_types)]
	if split == SPLIT_TYPE.VERTICAL:
		areas = splitv(dim)
	elif split == SPLIT_TYPE.HORIZONTAL:
		areas = splith(dim)
	
	
	for room in areas:
		var temp = recursive_gen(room,map)
		
		seperated.append(temp)
		rooms = concat(rooms,temp)
	
	if len(rooms)<=0:
		return [make_room(dim,map)]
	
	if len(rooms)<=1:
		return rooms
		
	connect_rooms(seperated[0],seperated[1],split)
	
	return rooms
	
func concat(list1,list2):
	for item in list2:
		list1.append(item)
	return list1

func splitv(dim):
	var slice = dim['x1'] + (dim['x2'] - dim['x1'])/2
	var area1 = {'x1':dim['x1'],'x2':slice,'y1':dim['y1'],'y2':dim['y2']}
	var area2 = {'x1':slice+1,'x2':dim['x2'],'y1':dim['y1'],'y2':dim['y2']}
	
	return [area1,area2]

func splitv2(dim):
	var p1 = int(split_density*(dim['x2']-dim['x1']))
	var p2 = int((1-split_density)*(dim['x2']-dim['x1']))
	var slice = int((rand_range(0,(p2-p1))) + dim['x1'])
	
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
	var slice = int(rand_range(0,(p2-p1)) + dim['y1'])
	
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
	
func connect_rooms(rooms1,rooms2,split_type):
	print(rooms1," -- : -- ",rooms2)
	find_max('x1','x2',rooms1)
	if split_type == SPLIT_TYPE.HORIZONTAL:
		var r1_max_x = find_max('x1','x2',rooms1)
		var r1_min_x = find_min('x1','x2',rooms1)
		var r2_max_x = find_max('x1','x2',rooms2)
		var r2_min_x = find_min('x1','x2',rooms2)
		pass
	if split_type == SPLIT_TYPE.VERTICAL:
		pass
	
	return
	
func find_max(key1,key2,list):
	var initial = list[0][key1]
	for item in list:
		initial = max(max(initial,item[key1]),item[key2])
	return initial
	
func find_min(key1,key2,list):
	var initial = list[0][key1]
	for item in list:
		initial = min(min(initial,item[key1]),item[key2])
	return initial