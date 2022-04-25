extends RigidBody2D

onready var hatch_area : Area2D = $hatcharea
onready var dissub_trim = self.get_rotation_degrees()
onready var rv_trim = get_parent().get_node("RescueSub").get_rotation_degrees()
onready var xfer_hatch = get_parent().get_node("RescueSub/TransferHatch")
onready var rv_cap = GlobalData.rvcap_get()
var mypartial:int = 0

signal mated(crew_size, mate_seal)
signal demated(mate_seal)

onready var crew_rem : int setget diss_rem_setter, diss_rem_getter
var crew_size : int setget crewsize_set, crewsize_get
onready var injured setget injured_set, injured_get
var mate_seal:bool = false

func _ready():
	dissub_init()

func dissub_init():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var nom_crew_size: int = 45
	crew_size = round(nom_crew_size + rng.randi_range(-15, 15))
	injured = round(crew_size * rng.randf_range(0, 0.5))
	crew_rem = crew_size

func injured_set(new_value):
	injured = new_value
	

func injured_get():
	return injured

func crewsize_set(new_value):
	crew_size = new_value

func crewsize_get():
	return crew_size

func diss_rem_setter(new_value):
	crew_rem = new_value

func diss_rem_getter():
	return crew_rem

func _on_hatchsensor_area_entered(area):	
	if area == xfer_hatch:
## Code comparison of RV and DISSUB trims so that a seal can be more realistic
		dissub_trim = round(self.get_rotation_degrees())
		rv_trim = round(get_parent().get_node("RescueSub").get_rotation_degrees())
		if abs(rv_trim - dissub_trim) < 3.0:
			mate_seal = true
			emit_signal("mated", crew_size, mate_seal)

func _on_hatchsensor_area_exited(area):
	mate_seal = false
	emit_signal("demated", mate_seal)
