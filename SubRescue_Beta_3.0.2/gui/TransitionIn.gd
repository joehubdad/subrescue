extends CanvasLayer

onready var _anim_player := $Anims

# Called when the node enters the scene tree for the first time.
func _ready():
	_anim_player.play_backwards("FadeIn")

func _scene_transition():
	_anim_player.play("FadeIn")
	yield(_anim_player, "animation_finished")
	
