extends Line2D

onready var player_anchor = $"../RescueSub/Position2D"
onready var voo_anchor = $"../VOO/Anchor"

func _process(delta):
	var player_relative_position = player_anchor.position - position
	points[1] = player_relative_position


