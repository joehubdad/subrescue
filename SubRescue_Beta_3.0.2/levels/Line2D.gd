extends Line2D

# Called when the node enters the scene tree for the first time.
func _ready():
	link_rope()

func _process(delta):
	link_rope()

func link_rope():
#	print(self.get_parent())
	var player = get_parent().get_node("RescueSub").global_position
	var ppos = Vector2(player.x+260,player.y+250)
#	print(player)
	var num_points = self.get_point_count()
#	print(self.get_point_position(num_points-1))
	self.set_point_position(num_points-1,ppos)
