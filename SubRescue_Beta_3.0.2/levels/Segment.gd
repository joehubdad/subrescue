extends RigidBody2D

var colliding : bool

#const color = [Color.red, Color.green]

func _ready():
	friction = 1.0

func _process(_delta):
	colliding = get_colliding_bodies().size() > 0
	deform()

func deform():
	var scale_x = 0.52
	var scale_y = 1
	var scale_range = 0.02
	var force = get_parent().get_parent().pull.length()/4
	var deform = clamp((scale_range / 80) * force, 0, scale_range)
	
	$Sprite.scale = Vector2((scale_x - deform), (scale_y + deform))
