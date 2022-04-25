extends ViewportContainer

#onready var viewport_dissub = get_node(cam_target).get_viewport()
onready var camera1 = $Viewport/HatchCam
#onready var DISSUB_cam = get_node(cam_target).get_camera2d()
func _ready():
	var waterimg = get_viewport().get_texture().get_data()
	$Viewport/background.texture = waterimg
	
	


func camera_activate():
	pass

func _on_Area2D_area_entered(area):
	emit_signal("DISSUBcontacted")
	camera_activate()
# Called when the node enters the scene tree for the first time.

#	camera1.target = get_node("RescueSub/Camera2D")
	




