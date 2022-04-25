## GenerateLevels.gd class script
extends Node2D

class_name GameLevel

# Modified by Eddie Kramer to generate an ocean depth, floor, and walls procedurally.
# Procedurally generates a tile-based map with a border.
# Right click or press enter to re-generate the map.

signal started()
signal finished()

enum Cell {SEAFLOOR, SEAWALLS}

## Attempt for Audio Bus Control..
onready var surf_sound = get_node("SurfZone/SurfSounds")
onready var deep_snd1 = get_node("DeepZone/Deepsounds1")
onready var deep_snd2 = get_node("DeepZone/Deepsounds2")
#export var inner_size := Vector2(10, 8)    # 10 x 8 grid?  Do I need to calc randomly?
#export var perimeter_size := Vector2(1, 1)
#export(float, 0 , 1) var ground_probability := 0.1

# Public variables
onready var size := Vector2(2000, 2000)
var grid_size := Vector2()

# Private variables
onready var _tile_map : TileMap = $TileMap
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
#	setup()
	$RescueSub.connect("rv_state_changed", self, "audio_controller")
	generate()
	var _transition = get_node("TransitionIn")
	_transition._scene_transition()


#
func setup() -> void:
	# Sets the game window size to twice the resolution of the world.
	var map_size_px := grid_size
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D, SceneTree.STRETCH_ASPECT_KEEP, map_size_px)
	OS.set_window_size(2 * map_size_px)


func generate() -> void:
	_rng.randomize()
	_tile_map.clear()
	emit_signal("started")
	grid_size = calculate_ocean_dimensions()
	generate_perimeter()
	generate_floor()
	emit_signal("finished")

func cam_panaroma():
	##Segment intended to start with main scene camera zoomed out, it zooms in slowly 
	# then the Sub camera is made current.
	var scene_cam = get_node("Camera2D")
	
	for _cam_zm in lerp(1.5,0.8,0.1):
		yield(get_tree().create_timer(0.5), "timeout")
		scene_cam.set_zoom(Vector2(_cam_zm,_cam_zm))


func calculate_ocean_dimensions() -> Vector2:
#	var depth_nom_cnt = 32
#	var depth_range = Vector2(-4,12)
	var ocean_breadth_cnt = 42
	var breadth_range = Vector2(-2,10)
	var ocean_cnts = Vector2(ocean_breadth_cnt + _rng.randi_range(breadth_range.x, breadth_range.y), 64)
	## Adjust background images and regions to fit new ocean boundaries
	$DeepZone/OceanDeep.set_scale(Vector2(ocean_cnts.x/31,ocean_cnts.y/23))
	$deptheffect.set_scale(Vector2(ocean_cnts.x/31,ocean_cnts.y/23))
	$SkyZone.set_scale(Vector2(ocean_cnts.x/29,1))
	$SurfZone.set_scale(Vector2(ocean_cnts.x/31,1))
	## Adjust the camera limits to stop at the edge of the ocean
	$RescueSub/AnchorCam2D.limit_right = (ocean_cnts.x+0.5)*64
	$RescueSub/AnchorCam2D.limit_bottom = (0.5*ocean_cnts.y+0.5)*64+330
	
	return ocean_cnts   ## A vector 2 value with x, y dimensions.
	
func generate_perimeter() -> void:
	# Builds left and right ocean "walls" based on vector2 variable size.
	# The two nested loops below place rotated tile pieces on the left and right sides.
	var depth_grid = grid_size.y
	var far_side = grid_size.x
	
	for y in range(0, depth_grid - 1, 4):
		_tile_map.set_cell(0, y, 0, true, false, true)

	for y in range(0, depth_grid - 1, 4):
		_tile_map.set_cell(far_side, y, 0,  false, false, true)

func generate_floor() -> void:
	# Fills the inside of the map the inner tiles from the remaining types: `Cell.GROUND` and `Cell.OBSTACLE` using the
	# `get_random_tile` function that takes the probability for `Cell.GROUND` tiles to have some more control
	# over what types of tiles we'll be placing.
	var oceanfloor
	var item_picker = _rng.randi_range(1,3)
	if item_picker == 1:
		oceanfloor = preload("res://levels/trench1.tscn").instance()
	elif item_picker == 2:
		oceanfloor = preload("res://levels/plain1.tscn").instance()
	elif item_picker == 3:
		oceanfloor = preload("res://levels/mountain1.tscn").instance()
#	var ocean_grid_span = grid_size.x
	var depth_grid = grid_size.y
#	for x in range(0, ocean_grid_span - 1, 4):
#		_tile_map.set_cell(x, depth_grid, 0, false, false, true).rotated(PI/4)
	add_child(oceanfloor)
	oceanfloor.global_position = Vector2(0, 0.5*depth_grid*64)


func audio_controller(state):
	print("audio controller in game gen fired. == ", state)
	if state == 0 or state == 1:
		surf_sound.play()
	else:
		surf_sound.stop()

	if state == 2 or state == 3:
		deep_snd1.play()
	else:
		deep_snd1.stop()
