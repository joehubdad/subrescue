extends Node2D

onready var audio = $introaudio
onready var startbut = $StartRescue
onready var optionsbut = $Options


func _ready():
	get_node("TransitionIn/Anims").play("FadeIn")
	audio.play()

func _unhandled_input(event):
	if Input.is_action_pressed('ui_start_main'):
		_on_Start_Rescue_pressed()
	elif Input.is_action_pressed('ui_focus_next'):
		if startbut.has_focus():
			optionsbut.grab_focus()
		else:
			startbut.grab_focus()
	elif Input.is_action_pressed('ui_focus_prev'):
		if startbut.has_focus():
			optionsbut.grab_focus()
		else:
			startbut.grab_focus()
	elif startbut.has_focus() and Input.is_action_pressed('ui_accept'):
		_on_Start_Rescue_pressed()
	elif optionsbut.has_focus() and Input.is_action_pressed('ui_accept'):
		_on_Options_pressed()

func _on_Start_Rescue_pressed():
	get_tree().change_scene("res://levels/GameLevel.tscn")
	yield(get_tree().create_timer(0.4),"timeout")


func _on_Options_pressed():
	get_tree().change_scene("res://gui/Options.tscn")
	yield(get_tree().create_timer(0.4),"timeout")
