extends RigidBody2D

export var spin_thrust = 25000

var rotation_dir = 6
var screensize

func _ready():
	screensize = get_viewport().get_visible_rect().size


func _physics_process(_delta):
	applied_torque = rotation_dir * spin_thrust



func _on_RescueSub_in_surf_zone():
	applied_torque = 50000
