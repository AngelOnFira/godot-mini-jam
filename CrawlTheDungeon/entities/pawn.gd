extends Node2D

enum CELL_TYPES { EMPTY = -1, ACTOR, OBSTACLE, OBJECT }
export(CELL_TYPES) var type = ACTOR