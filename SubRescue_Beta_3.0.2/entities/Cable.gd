extends Node2D


export (float) var ropeLength = 200
export (float) var constrain = 1	# distance between points
export (Vector2) var gravity = Vector2(0,9.8)
export (float) var dampening = 0.9
export (bool) var startPin = true
export (bool) var endPin = true
onready var voo_pin_point = Vector2()
onready var sub_pin_point = Vector2()

onready var line2D: = $Line2D

var pos: PoolVector2Array
var posPrev: PoolVector2Array
var pointCount: int

func _ready()->void:
	pointCount = get_pointCount(ropeLength)
	resize_arrays()
	voo_pin_point = get_parent().get_parent().get_node("VOO/VOOdeck/CollisionShape2D").get_global_position()
	set_start(Vector2(voo_pin_point.x - 920,voo_pin_point.y - 20))
	sub_pin_point = get_parent().get_parent().get_node("RescueSub").get_global_position()
	set_last(Vector2(sub_pin_point.x - 645,sub_pin_point.y + 180))
	init_position()

func get_pointCount(distance: float)->int:
	return int(ceil(distance / constrain))

func resize_arrays():
	pos.resize(pointCount)
	posPrev.resize(pointCount)

func init_position()->void:
	for i in range(pointCount):
		pos[i] = position + Vector2(constrain *i, 0)
		posPrev[i] = position + Vector2(constrain *i, 0)
	position = Vector2.ZERO

func _process(delta)->void:
	voo_pin_point = get_parent().get_parent().get_node("VOO/VOOdeck/CollisionShape2D").get_global_position()
	set_start(Vector2(voo_pin_point.x - 920,voo_pin_point.y - 20))
	sub_pin_point = get_parent().get_parent().get_node("RescueSub").get_global_position()
	set_last(Vector2(sub_pin_point.x - 645,sub_pin_point.y + 180))
	update_points(delta)
	update_constrain()
	print("1st:", voo_pin_point, "sub:", sub_pin_point)
	print(pos[pointCount-1])
	#update_constrain()	#Repeat to get tighter rope
	#update_constrain()
	
	# Send positions to Line2D for drawing
	line2D.points = pos

func set_start(p:Vector2)->void:
	pos[0] = p
	posPrev[0] = p

func set_last(p:Vector2)->void:
	pos[pointCount-1] = p
	posPrev[pointCount-1] = p

func update_points(delta)->void:
	for i in range (pointCount):
		# not first and last || first if not pinned || last if not pinned
		if (i!=0 && i!=pointCount-1) || (i==0 && !startPin) || (i==pointCount-1 && !endPin):
			var velocity = (pos[i] -posPrev[i]) * dampening
			posPrev[i] = pos[i]
			pos[i] += velocity + (gravity * delta)

func update_constrain()->void:
	for i in range(pointCount):
		if i == pointCount-1:
			return
		var distance = pos[i].distance_to(pos[i+1])
		var difference = constrain - distance
		var percent = difference / distance
		var vec2 = pos[i+1] - pos[i]
		
		# if first point
		if i == 0:
			if startPin:
				pos[i+1] += vec2 * percent
			else:
				pos[i] -= vec2 * (percent/2)
				pos[i+1] += vec2 * (percent/2)
		# if last point, skip because no more points after it
		elif i == pointCount-1:
			pass
		# all the rest
		else:
			if i+1 == pointCount-1 && endPin:
				pos[i] -= vec2 * percent
			else:
				pos[i] -= vec2 * (percent/2)
				pos[i+1] += vec2 * (percent/2)
