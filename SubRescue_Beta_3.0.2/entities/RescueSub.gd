extends KinematicBody2D

const FLOOR_NORMAL: = Vector2.UP

signal saved(crew_saved, crew_rem, full_rv)
signal trim_changed(sub_trim)
signal rv_state_changed(state)

export var motor_speed: = Vector2(150.0, 150.0)  #x,y component speeds when using motors
var boost_speed: = Vector2(250.0,250.0)
export var current_force = Vector2(0,0) setget set_cur, get_cur
export var gravity_force: = Vector2(0,150)  # gravity velocity acting on sub
export var bouyant_force: = Vector2(0,150) # bouyant force velocity of sub
const INJURED_TIME: = 1.8    # Constant depicting the slow xfr rate of injured rescuees
const HEALTHY_TIME: = 0.8	 # Constant depicting a normal health xfr rate

onready var time_period : float = HEALTHY_TIME setget xfer_set, xfer_get    # 500 ms

var time = 0 

onready var surf_sound = $SurfSounds
onready var deep_sound = $Deepsounds1
onready var deep_sound2 = $Deepsounds2
onready var hud_display = get_parent().get_node("HUD")
onready var dissub_unit = get_parent().get_node("DISSUB")
onready var toggle_lights = false

onready var velocity = Vector2()
onready var sub_trim = 0.0    #Sub trim up or down in degrees; default is ZERO bubble
onready var depth = 0

onready var crew_saved = 0  ## local session counter
onready var seal_check : bool = false

onready var rvcap = GlobalData.rvcap_get()
onready var crewsz
onready var crewrem
onready var full_rv : bool setget full_rv_set, full_rv_get

func _ready():
	dissub_unit.connect("mated", self, "_on_DISSUB_mated")
	dissub_unit.connect("demated", self, "_on_DISSUB_demated")
	pass


enum {
	SKY,
	SURFACE,
	DEEPSEA,
	RESCUEOPS
}

var state = SKY


func get_motion():
	# Detect up/down/left/right keystate and only move when pressed\
	velocity = Vector2(current_force.x, bouyant_force.y + gravity_force.y + current_force.y)
	if Input.is_action_pressed('ui_right'):
		if Input.is_action_pressed('ui_boost'):
			velocity.x += 1.5 * motor_speed.x
		else:
			velocity.x += motor_speed.x
	if Input.is_action_pressed('ui_left'):
		if Input.is_action_pressed('ui_boost'):
			velocity.x -= 1.5 * motor_speed.x
		else:
			velocity.x -= motor_speed.x
	if Input.is_action_pressed('ui_down'):
		if Input.is_action_pressed('ui_boost'):
			velocity.y += bouyant_force.y + boost_speed.y + gravity_force.y
		else:
			velocity.y += bouyant_force.y + motor_speed.y + gravity_force.y
	if Input.is_action_pressed('ui_up'):
		if Input.is_action_pressed('ui_boost'):
			velocity.y += bouyant_force.y - boost_speed.y + gravity_force.y
		else:
			velocity.y += bouyant_force.y - motor_speed.y + gravity_force.y
	if Input.is_action_pressed('rescue'):
		velocity = Vector2.ZERO
#	velocity = velocity.normalized()

func get_trim():
	if Input.is_action_pressed("trim_down"):
		sub_trim -= 0.2
		self.set_rotation_degrees(sub_trim)
	if Input.is_action_pressed("trim_up"):
		sub_trim += 0.2
		self.set_rotation_degrees(sub_trim)
	emit_signal("trim_changed", sub_trim)

func _physics_process(delta: float) -> void:
	match state:
		SKY:
			sky_state()
			get_motion()
		SURFACE:
			surface_state()
			hud_display.update_gages()
			get_motion()
		DEEPSEA:
			deepsea_state()
#			get_trim()
			get_motion()
			hud_display.update_gages()
		RESCUEOPS:
			rescue_operations()
#			get_trim()
			get_motion()
			hud_display.update_gages()
#	gauge_updates()
# warning-ignore:return_value_discarded
	move_and_slide(velocity)


func sky_state():
	gravity_force = Vector2(0,150)
	bouyant_force = gravity_force
	full_rv = false
	hud_display.null_init()

func surface_state():
	gravity_force = Vector2(0,98)
	bouyant_force = Vector2(0,-98)
	get_trim()

	
func deepsea_state():
	bouyant_force = Vector2(0,-30)
	gravity_force = Vector2(0,0)
	get_trim()
	

## Lights toggle on and off.
func _unhandled_input(event):
	if event.is_action_pressed("toggle_lights"):
		toggle_lights = !toggle_lights
		$aftFlood.set_enabled(toggle_lights)
		$fwdFlood.set_enabled(toggle_lights)

func _process(delta):
	time += delta

func on_timeout_complete():
	pass

func rescue_operations():
	get_trim()
	if dissub_unit.diss_rem_getter() > 0 and !full_rv and seal_check:
		if dissub_unit.injured_get() > 0:
			xfer_set(INJURED_TIME)
		else:
			xfer_set(HEALTHY_TIME)

		if time > time_period:
#			print("the time period ", time_period, " num injured ", dissub_unit.injured_get())
			crew_saved += 1
			dissub_unit.diss_rem_setter(dissub_unit.diss_rem_getter()-1)
			if dissub_unit.injured_get() > 0:
				dissub_unit.injured_set(dissub_unit.injured_get() - 1)
#			print("saved ", crew_saved, " remaining is ", dissub_unit.diss_rem_getter())
			emit_signal("saved", dissub_unit.diss_rem_getter(), full_rv)
			if crew_saved == rvcap:
				full_rv = true
				crew_saved = 0
				state = DEEPSEA
			time = 0
	else:
		state = DEEPSEA
		

func xfer_set(new_value):
	time_period = new_value

func xfer_get():
	return time_period

func set_cur(new_value):
	current_force = new_value
	
func get_cur():
	return current_force

func _on_SurfZone_body_entered(body):
	if body == self:
		state = SURFACE
		## note - if RV comes up and has rescued > 0 survivors, the res_try should go up!
		## this code is handled within the rescuequeery popup dialog
		emit_signal("rv_state_changed", state)

func _on_SurfZone_body_exited(body):
	state = DEEPSEA

func _on_DISSUB_mated(crew_size, mate_seal):
	#local variables initialized.
	seal_check = mate_seal
	crew_size = crew_size
	state = RESCUEOPS

func _on_DISSUB_demated(mate_seal):
	seal_check = mate_seal
	state = DEEPSEA


func _on_SkyZone_body_entered(body):
	if body == self:
		state = SKY


func _on_SkyZone_body_exited(body):
	state = SURFACE


func _on_DeepZone_body_entered(body):
	if body == self:
		state = DEEPSEA
		emit_signal("rv_state_changed", state)


func _on_DeepZone_body_exited(body):
	state = SURFACE

func full_rv_set(new_value):
	full_rv = new_value

func full_rv_get():
	return full_rv
#
#func _on_rescuequeery_next_sortie(srt_try):
#	next_sort = srt_try
#	pass # Replace with function body.


