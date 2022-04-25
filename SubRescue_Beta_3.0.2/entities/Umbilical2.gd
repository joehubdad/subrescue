extends Node2D

export (float) var ropeLength = 160 #feet or pixels...
onready var startTarget = get_parent().get_node("RescueSub")
#get_parent().get_node("RescueSub")
onready var endTarget = get_parent().get_node("VOO/Anchor")
#get_parent().get_node("VOO")
onready var segment = preload("res://entities/Segment.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_umbilical()

func generate_umbilical() -> void:
	var joint_calc = round(ropeLength)  #approx 3.2 px per segment
	
	for i in range(0, joint_calc, 1):
		var new_segment = segment.instance()
		new_segment.position = Vector2(100,20+3*i)
		add_child(new_segment)

#		if i == 0:
#			new_segment.node_a = startTarget
#			new_segment.node_b = new_segment
#		elif i == joint_calc - 1:
#			new_segment.node_a = get_node("Segment"%(i-1))
#			new_segment.node_b = endTarget
#		if i == 0:
#			var this_node = "Umbilical2/Segment"
#			new_segment.get_child(2).node_b = NodePath(this_node)
#			print(new_segment.name)
#		if i > 0:
#			var string_before = "Segment%d"
#			var node_before = string_before % [i-1]
#			new_segment.get_child(2).node_a = NodePath(node_before)
#			print(i)
#			print(new_segment.name)
#			var string_this_node = "Segment%d"
#			var this_node = string_this_node % [i]
#			new_segment.get_child(2).node_b = NodePath(this_node)



