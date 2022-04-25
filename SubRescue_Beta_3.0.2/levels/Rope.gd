extends Node2D

var p2joint
var ppos
var p2pos
var strain
# Simulation variable used to lengthen the hose during game play
var hose_length
# Below length factor constant establishes roughly 200ft length when Rescue Sub
# is at 107 FSW.
var length_factor = 3.75
var linked := false
var pull : Vector2
var pull2 : Vector2

onready var num_segs = $Segments.get_child_count()
onready var player = get_parent().get_node("RescueSub")
onready var player2 = get_parent().get_node("VOO")

export(float, 1.0, 5.0) var pull_factor = 2.5
export(int, 1, 20) var minimum_distance = 1
export(float, 0.0, 1.0) var priority_percent = 0.2

func _ready():
	#link_players()
	pass

func _physics_process(_delta):
	if linked:
		calc_pull()
		calc_length()
		var strain = player2.global_position.distance_to(player.global_position)/length_factor
		if strain>hose_length:
			#add_segments()
			pass
#		if hose_length>strain:
#			reel_in_segments()

func link_players():
	
	#prevents the rope from freaking out, when relocated
	yield(get_tree(), "idle_frame")
	
	p2joint = get_parent().get_node("VOO/voo_joint")
	p2pos = p2joint.global_position 
	p2joint.node_b = $Segments.get_node("AnchorSegment").get_path()
	
	player = get_parent().get_node("RescueSub")
	ppos = player.get_node("Position2D").global_position
	var pseg = $Segments.get_child(0)
	var pjoint = pseg.get_node("PinJoint2D")
	pjoint.node_b = player.get_path()
	
	linked = true

func calc_length():
	hose_length = num_segs*9.5

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

func add_segments():

	yield(get_tree(), "idle_frame")
	
	var rope_anchor = get_parent().get_node("Rope/Segments/AnchorSegment")
	rope_anchor.set_physics_process(false)

	player = get_parent().get_node("RescueSub")
	player2 = get_parent().get_node("VOO")

	player2.set_physics_process(false)
	player.set_physics_process(false)
	player.set_process_input(false)
	
	var segs_list = $Segments.get_children()
	var last_seg = segs_list[num_segs-2]
	var seg_dup = last_seg.duplicate(15)
	seg_dup.rotate(PI)
	seg_dup.set_physics_process(false)
	$Segments.add_child_below_node(last_seg, seg_dup, true)

	var dupjoint = seg_dup.get_node("PinJoint2D")
	dupjoint.node_b = last_seg.get_path()
	num_segs = $Segments.get_child_count()
	rope_anchor.get_node("PinJoint2D").node_b = seg_dup.get_path()

	player2.set_physics_process(true)
	player.set_physics_process(true)
	player.set_process_input(true)

	rope_anchor.set_physics_process(true)

func _unhandled_input(event):
	if event.is_action_pressed("retrieve"):
		reel_in_segments()

func reel_in_segments():
	
	yield(get_tree(), "idle_frame")
	
	var rope_anchor = get_parent().get_node("Rope/Segments/AnchorSegment")
	rope_anchor.set_physics_process(false)

	player = get_parent().get_node("RescueSub")
	player2 = get_parent().get_node("VOO")
	player2.set_physics_process(false)
	player.set_physics_process(false)
	player.set_process_input(false)
	
	var segs_list = $Segments.get_children()
	var seg2remove = segs_list[num_segs-2]
	var seg_new_last = segs_list[num_segs-3]
	rope_anchor.get_node("PinJoint2D").node_b = seg_new_last.get_path()
	$Segments.remove_child(seg2remove)
	seg2remove.queue_free()

	player2.set_physics_process(true)
	player.set_physics_process(true)
	player.set_process_input(true)

	rope_anchor.set_physics_process(true)


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

