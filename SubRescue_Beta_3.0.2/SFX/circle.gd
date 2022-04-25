extends CanvasLayer

onready var anims = $anim

func _ready():
	pass

func _on_TextureButton_pressed():
	print("the button was pushed")
	anims.play("intro")
