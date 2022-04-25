extends Node2D

var p2joint
var ppos
var p2pos
var strain

var linked := false
var pull : Vector2
var pull2 : Vector2

onready var num_segs = $Segments.get_child_count()
onready var player = get_parent().get_node("RescueSub")
onready var player2 = get_parent().get_node("VOO")

export(float, 1.0, 5.0) var pull_factor = 2.5
export(int, 1, 20) var minimum_distance = 1
export(float, 0.0, 1.0) var priority_percent = 0.2

func calc_pull():
	
	# the pull of the rope is the sum of the distance between each segment's south pole
	# and their neighbor's north pole (think of magnets)
	# 'relevant' segments determine the direction of the pull, 
	# whereas all segments together determine the overall force.
	# segments are considered relevant, if they are closer to the current player,
	# than the first colliding segment (from the current player's pov)
	
	pull = Vector2.ZERO
	
	var direction = p2joint.global_position.direction_to(p2pos)
	var force = direction * p2joint.global_position.direction_to(p2pos)
	var relevant = find_relevant(true)
	
	pull2 = Vector2.ZERO
	var newp2pos = player2.global_position + p2pos
	var direction2 = $Segments.get_child(0).get_node("PinJoint2D").global_position.direction_to(newp2pos)
	var force2 = direction * $Segments.get_child(0).get_node("PinJoint2D").global_position.distance_to(newp2pos)
	var relevant2 = find_relevant(false)
	
	for i in $Segments.get_children():
		var p := Vector2.ZERO
		
		var next = null
		var next_idx = i.get_index() + 1
		if next_idx < $Segments.get_children().size():
			next = $Segments.get_child(next_idx)
		
		if next:
			var n = i.get_node("North_Pole").global_position
			var s = next.get_node("South_Pole").global_position
			p = s.direction_to(n) * s.distance_to(n)
			
			#add force percentage to p, so longer distances gain priority
			p *= (1 + p.length()/(1.0/priority_percent))
		
		force += p
		if relevant.has(i):
			direction += p
		
		force2 += p
		if relevant2.has(i):
			direction2 += p
	
	pull = direction.normalized() * force.length() * pull_factor
	pull2 = -1 * direction2.normalized() * force2.length() * pull_factor
	
	if pull.length() < minimum_distance:
		pull = Vector2.ZERO
	if pull2.length() < minimum_distance:
		pull2 = Vector2.ZERO
	
	player = get_parent().get_node("RescueSub")
	player.pull = pull
	player2.pull = pull2

func find_relevant(var for_player1: bool) -> Array:
	var r = []
	
	var c = $Segments.get_children()
	
	#since player1 is at the end of the chain, the Array has to be looped over backwards.
	if for_player1:
		c.invert()
	
	for i in c:
		r.append(i)
		if i.colliding:
			break
	
	if for_player1:
		r.invert()
	return r

