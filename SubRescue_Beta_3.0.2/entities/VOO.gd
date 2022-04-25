## VOO.gd
extends KinematicBody2D

const FLOOR_NORMAL: = Vector2.UP

var pull := Vector2.ZERO

export var gravity_force: = Vector2(0,98)  # gravity velocity acting on VOO
export var bouyant_force: = Vector2(0,-30) # bouyant force velocity of VOO
onready var velocity: = Vector2(0,0)

func _on_Surf_body_entered(_body):
	bouyant_force = Vector2(0,-98)

