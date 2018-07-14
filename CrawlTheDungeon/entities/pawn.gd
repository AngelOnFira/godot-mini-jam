extends Node2D

enum CELL_TYPES { EMPTY = -1, ACTOR=143, OBSTACLE, OBJECT }
export(CELL_TYPES) var type = ACTOR