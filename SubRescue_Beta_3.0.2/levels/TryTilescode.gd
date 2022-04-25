extends Node2D


# Private variables
onready var _tile_map : TileMap = $TileMap
onready var _ocean = $Ocean   #2048 wide by 1536 tall node for the sprite

func _ready() -> void:
	_tile_map.set_cell(0, 0, 0, true, false, true)
	_tile_map.set_cell(1, 4, 0, true, false, true)
	_tile_map.set_cell(0, 8, 0)
	_tile_map.set_cell(4, 8, 0)
	_tile_map.set_cell(8, 8, 0)
	_tile_map.set_cell(11, 0, 0, false, false, true)
	_tile_map.set_cell(11, 4, 0, false, false, true)
	_ocean.scale = Vector2(0.375,0.36)
