extends Area2D

onready var resvessel = get_parent().get_node("RescueSub")
onready var dissub = get_parent().get_node("DISSUB")
var timer = 0.0
var time_period = 2.0
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	timer += delta
	if timer >= 12:
		dissub.linear_velocity.x = 0
	elif timer >= 3:
		dissub.linear_velocity.x = -20
	else:
		dissub.linear_velocity.x = 40

func _on_currentshallow_body_entered(body):
	if body == resvessel:
		resvessel.set_cur(Vector2(-20,0))

func _on_currentshallow_body_exited(body):
	if body == resvessel:
		resvessel.set_cur(Vector2(0,0))
