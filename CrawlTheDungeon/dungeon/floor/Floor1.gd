extends Node
enum TILE {_floor = 0,_wall_left,_wall_right,_wall_up,_wall_down,_wall_center}

func _ready():
	# Called when the node is added to the scene for the first time.
	# Initialization here
	generate_dungeon(16,25,2)
	pass

func generate_dungeon(height,width,depth):
	$"Floor".clear()
	var map = []
	var dim = {'x1':0,'x2':width,'y1':0,'y2':height}
	for x in range(width):
		var col = []
		col.resize(height)
		map.append(col)
	
	rec_vertical(dim,depth,map)
	
	print(map)
	for x in range(0,width):
		for y in range(0,height):
			if not map[x][y] == null:
				$"Floor".set_cell(x,y,map[x][y])
	print('Generation Done')
	
func rec_vertical(dim,depth,map):
	#Base case / creating the size of the room : note to change
	if depth == 0:
		var px1 = (randi()%(dim['x2']-dim['x1']))+dim['x1'] 
		var py1 = (randi()%(dim['y2']-dim['y1']))+dim['y1'] 
		
		var px2 = (randi()%(dim['x2']-dim['x1']))+dim['x1'] 
		var py2 = (randi()%(dim['y2']-dim['y1']))+dim['y1'] 
		
		var room = {'x1':min(px1,px2),'x2':max(px1,px2),'y1':min(py1,py2),'y2':max(py1,py2)}
		for x in range(room['x1'],room['x2']):
			for y in range(room['y1'],room['y2']):
				map[x][y] = TILE._floor
		print(room)
		return room
		
	#dividing up the rooms
	var slice = dim['x1'] + (dim['x2'] - dim['x1'])/2
	var area1 = {'x1':dim['x1'],'x2':slice,'y1':dim['y1'],'y2':dim['y2']}
	var area2 = {'x1':slice,'x2':dim['x2'],'y1':dim['y1'],'y2':dim['y2']}
	var room1 = rec_horizontal(area1,depth-1,map)
	var room2 = rec_horizontal(area2,depth-1,map)

	#Need to find a line in the range that two rectangles can connect
	#var y_min = max(room1['y1'],room2['y1'])
	#var y_max = min(room1['y2'],room2['y2'])
	
func rec_horizontal(dim,depth,map):
	if depth == 0:
		var px1 = (randi()%(dim['x2']-dim['x1']))+dim['x1'] 
		var py1 = (randi()%(dim['y2']-dim['y1']))+dim['y1'] 
		
		var px2 = (randi()%(dim['x2']-dim['x1']))+dim['x1'] 
		var py2 = (randi()%(dim['y2']-dim['y1']))+dim['y1'] 
		
		var room = {'x1':min(px1,px2),'x2':max(px1,px2),'y1':min(py1,py2),'y2':max(py1,py2)}
		print(room)
		for x in range(room['x1'],room['x2']):
			for y in range(room['y1'],room['y2']):
				map[x][y] = TILE._floor
		return room
		
	var slice = dim['y1'] + (dim['y2'] - dim['y1'])/2
	var area1 = {'x1':dim['x1'],'x2':dim['x2'],'y1':dim['y1'],'y2':slice}
	var area2 = {'x1':dim['x1'],'x2':dim['x2'],'y1':slice,'y2':dim['y2']}
	var room1 = rec_vertical(area1,depth-1,map)
	var room2 = rec_vertical(area2,depth-1,map)