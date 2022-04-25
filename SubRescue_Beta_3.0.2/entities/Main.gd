extends Node

onready var viewport1 = $Viewports/ViewportContainer/Viewport
onready var viewport2 = $miniView/Viewport2
onready var camera1 = $Viewports/ViewportContainer/Viewport/Camera2D
#onready var camera2 = $Viewports/ViewportContainer2/Viewport2/Camera2D
onready var world = $Viewports/ViewportContainer/Viewport/BaseLevel

func _ready():
#	viewport2.world_2d = viewport1.world_2d
	camera1.target = world.get_node("RescueSub")
#	camera2.target = world.get_node("RescueSub")
	$miniView/Viewport2.world_2d = viewport1.world_2d
#	set_camera_limits()
#
#
#func set_camera_limits():
#	var map_limits = world.get_used_rect()
#	var map_cellsize = world.cell_size
#	for cam in [camera1]:
#		cam.limit_left = map_limits.position.x * map_cellsize.x
#		cam.limit_right = map_limits.end.x * map_cellsize.x
#		cam.limit_top = map_limits.position.y * map_cellsize.y
#		cam.limit_bottom = map_limits.end.y * map_cellsize.y
