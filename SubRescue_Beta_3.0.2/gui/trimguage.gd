extends Control

onready var rescuesub = get_parent().get_parent().get_node("RescueSub")
onready var upangle = $VBoxContainer/downangle
onready var downangle = $VBoxContainer/upangle

# Called when the node enters the scene tree for the first time.
func _ready():
	rescuesub.connect("trim_changed", self, "_on_trim_changed")

# So both up and down angle segments must work in tandem.
func _on_trim_changed(new_angle):
	var bluetransparent = Color(0.0,0.97,0.16,0.77)
	upangle.set_tint_progress(bluetransparent)
	downangle.set_tint_progress(bluetransparent)
	if new_angle > 0:
		downangle.value = 0
		upangle.value = new_angle
	elif new_angle <= 0:
		upangle.value = 0
		downangle.value = abs(new_angle)
	pass
