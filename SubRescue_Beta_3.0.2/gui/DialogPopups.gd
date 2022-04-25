extends Control

## state variable tracking when RV is empty
var rvstate_diag : int setget rvstate_set, rvstate_get

onready var mcaudio = $missioncomplete
onready var sortieaudio = $sortiecomplete
onready var offloadmenu = $offload2
onready var completemenu = $complete2
var rvtrim = 0

onready var rv_sub = get_parent().get_parent().get_node("RescueSub")
onready var dissub = get_parent().get_parent().get_node("DISSUB")


func _ready():
	rv_sub.connect("trim changed", self, "on_rv_trim_change")

func _unhandled_input(event):
	
	if event.is_action_pressed("interact") and rvstate_diag == 1 and dissub.diss_rem_getter() > 0 and abs(rvtrim)<=10:
		offloadmenu.show()
	elif event.is_action_pressed("interact") and rvstate_diag == 1 and dissub.diss_rem_getter() <= 0 and abs(rvtrim)<=10:
		completemenu.show()
		mcaudio.play()
	
	if offloadmenu.visible and event.is_action_pressed("ui_accept"):
		_on_offloadconfirm_pressed()
	elif offloadmenu.visible and event.is_action_pressed("ui_cancel"):
		offloadmenu.hide()

	if completemenu.visible and event.is_action_pressed("ui_accept"):
		_on_completeconfirm_pressed()
	elif completemenu.visible and event.is_action_pressed("ui_cancel"):
		completemenu.hide()
		## Code here to exit the game
	

func rvstate_set(new_value):
	rvstate_diag = new_value

func rvstate_get():
	return rvstate_diag

func _on_offloadconfirm_pressed():
	offloadmenu.hide()
	rv_sub.full_rv_set(false)
	sortieaudio.play()
	yield(sortieaudio, "finished")
	## Code some animation and audio in the game to illustrate offloading survivors.


func _on_completeconfirm_pressed():
	## Eventually code restarting the Game Level generator
	get_tree().change_scene("res://levels/GameLevel.tscn")


func _on_canxoffload_pressed():
	offloadmenu.hide()


func _on_canxrescue_pressed():
	get_tree().quit()
	completemenu.hide()


func on_rv_trim_change(new_trim):
	rvtrim = new_trim
