extends RigidBody2D

# Called when the node enters the scene tree for the first time.
signal found
signal departed

func _ready():
	pass # Replace with function body.

func _on_hatcharea_body_entered(body):
	emit_signal("found")

func _on_hatcharea_body_exited(body):
	emit_signal("departed")
