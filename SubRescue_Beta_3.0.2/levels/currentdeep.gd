extends Area2D

onready var resvessel = get_parent().get_node("RescueSub")


func _on_currentdeep_body_entered(body):
	print("entered deep current area. ")
	if body == resvessel:
		resvessel.set_cur(Vector2(90,0))
		print(resvessel.get_cur())


func _on_currentdeep_body_exited(body):
	print("exited deep current area. ")
	if body == resvessel:
		resvessel.set_cur(Vector2(0,0))
