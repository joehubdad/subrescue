extends Node2D

onready var _transition := $TransitionIn

func _ready():
	pass # Replace with function body.


func _on_transitionbutton_pressed():
	print("button pushed")
	_transition._scene_transition()
