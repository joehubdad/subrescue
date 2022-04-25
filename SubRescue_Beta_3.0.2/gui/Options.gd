extends CanvasLayer

onready var abouttxt = $about/aboutrescue
onready var controlsimg = $controls/gamecontrols
onready var menuaudio = $optionsaudio

onready var about = $about
onready var controls = $controls
onready var back = $back

func _ready():
	init()
	pass


func _unhandled_input(event):
	if Input.is_action_pressed('ui_start_main'):
		_on_back_pressed()
	elif Input.is_action_pressed('ui_focus_next'):
		if about.has_focus():
			about.focus_next()
		elif controls.has_focus():
			controls.focus_next()
		elif back.has_focus():
			back.focus_next()
	elif Input.is_action_pressed('ui_focus_previous'):
		if about.has_focus():
			about.focus_previous()
		elif back.has_focus():
			back.focus_previous()
		elif controls.has_focus():
			controls.focus_previous()
	elif about.has_focus() and Input.is_action_pressed('ui_accept'):
		_on_about_pressed()
	elif controls.has_focus() and Input.is_action_pressed('ui_accept'):
		_on_controls_pressed()
	elif back.has_focus() and Input.is_action_pressed('ui_accept'):
		_on_back_pressed()

func init():
	menuaudio.play()
	about.grab_focus()

func _on_about_pressed():
	controlsimg.set_visible(false)
	yield(get_tree().create_timer(0.4),"timeout")
	abouttxt.set_visible(true)

func _on_controls_pressed():
	abouttxt.set_visible(false)
	yield(get_tree().create_timer(0.4),"timeout")
	controlsimg.set_visible(true)
	

func _on_back_pressed():
	get_tree().change_scene("res://levels/Intro.tscn")
	yield(get_tree().create_timer(0.4),"timeout")
