extends CanvasLayer

signal rescue_completed
export var ttcr = 20
onready var mytimer = $RescueTimer
onready var readout_lbl = $RescueProgress/TimerReadout

# Called when the node enters the scene tree for the first time.
func _ready():
	mytimer.set_wait_time(ttcr)
	readout_lbl.hide()




func _on_RescueTimer_timeout():
	emit_signal("rescue_completed")

