extends CanvasLayer

onready var player = get_parent().get_node("RescueSub")
onready var dissub = get_parent().get_node("DISSUB")
onready var surfsnd = get_parent().get_node("SurfZone/SurfSounds")
onready var deepsnd1 = get_parent().get_node("DeepZone/Deepsounds1")
onready var deepsnd2 = get_parent().get_node("DeepZone/Deepsounds2")
onready var game_score = $Score_Status/vbox/score/score/game_score
onready var souls_saved = $Score_Status/vbox/totsaves/score/game_saves
onready var xferaudio = $xfercomplete
onready var timetext = $Score_Status/vbox/rescuetime/time/time
var game_time = 0.0 
export var rv_state = 0
var depth : float
onready var crew_sizeg : int
onready var crew_savedg : int
var persons_saved  ##global value?
var career_score
var xfer_seal : bool = false
var seal_counter : int = 0
var sort_track = 0
var offloaded : bool = true

func _ready():
	dissub.connect("mated", self, "_on_DISSUB_mated")
	dissub.connect("demated", self, "_on_DISSUB_demated")
	player.connect("saved", self, "_on_RescueSub_saved")
	player.connect("rv_state_changed", self, "_on_RescueSub_rv_state_changed")
	$rescuequeery.connect("next_sortie", self, "_update_sortie_num")
	null_init()

func _process(delta):
	game_time += delta

func globals_init():
	persons_saved = GlobalData.saves_get()
	career_score = GlobalData.score_get()

func null_init():
	globals_init()
	$Console/Guage/Rescue_depth.text = " "
	$Console/Guage2/Rescue_internal.text = String("%.1f" % 14.7)
	$Console/Guage3/Rescue_seapress.text = String("%.1f" % 14.7)
	$Console/Guage4/TS_press.text = String("%.1f" % 14.7)
	$Mating/MatingStatus/ColorRect/MateStatus.text = "NO SEAL"
	$Mating/MatingStatus/ColorRect/MateStatus.add_color_override("font_color",Color( 1, 0, 0, 1 ))
	$crewstats/MatingStatus/ColorRect/CrewStatus.text = "UNKNOWN"
	$crewstats/MatingStatus/ColorRect/CrewStatus.add_color_override("font_color",Color( 1, 0, 0, 1 ))
	$crewsaves/MatingStatus/ColorRect/SavesStatus.text = "0"
	souls_saved.text = String("%d" % GlobalData.saves_get())
	game_score.text = String("%d" % GlobalData.score_get())
	timetext.text = String("%02d" % 0.0)
	update_gages()
	

func update_gages():
	var pposy = player.global_position.y
	depth = pposy/2
	var RV_press = 14.7
	var sea_press = depth * 0.4
	var TS_press = sea_press
	yield(get_tree().create_timer(0.6), "timeout")
	$crewsaves/MatingStatus/ColorRect/SavesStatus.text = String("%d" % crew_savedg)
	$Console/Guage/Rescue_depth.text = String("%.1f" % depth)
	$Console/Guage2/Rescue_internal.text = String("%.1f" % RV_press)
	$Console/Guage3/Rescue_seapress.text = String("%.1f" % sea_press)
	$Console/Guage4/TS_press.text = String("%.1f" % TS_press)
	souls_saved.text = String("%d" % GlobalData.saves_get())
	game_score.text = String("%d" % GlobalData.score_get())
	timetext.text = String(_format_seconds(game_time,false))
	
	if xfer_seal:
		TS_press = RV_press
		$Mating/MatingStatus/ColorRect/MateStatus.text = "SEALED"   ## Green color if seal.
		$Mating/MatingStatus/ColorRect/MateStatus.add_color_override("font_color",Color( 0, 1, 0, 1 ))
		$Console/Guage4/TS_press.text = String("%.2f" % TS_press)
	else:
		$Mating/MatingStatus/ColorRect/MateStatus.text = "NO SEAL"   ## RED color if no seal
		$Mating/MatingStatus/ColorRect/MateStatus.add_color_override("font_color",Color( 1, 0, 0, 1 ))

	## A counter check to maintain the gage updated after making contact with the DISSUB.
	if seal_counter > 0:
		$crewstats/MatingStatus/ColorRect/CrewStatus.text = String("%d" % crew_sizeg)
		$crewstats/MatingStatus/ColorRect/CrewStatus.add_color_override("font_color",Color( 0, 1, 0, 1 ))
		$crewsaves/MatingStatus/ColorRect/SavesStatus.text = String("%d" % crew_savedg)
	else:
		$crewstats/MatingStatus/ColorRect/CrewStatus.text = "UNKNOWN"
		$crewstats/MatingStatus/ColorRect/CrewStatus.add_color_override("font_color",Color( 1, 0, 0, 1 ))
		$crewsaves/MatingStatus/ColorRect/SavesStatus.text = String("%d" % 0)


func _on_DISSUB_mated(crew_size, mate_seal):
	xfer_seal = mate_seal
	seal_counter += 1
	crew_sizeg = crew_size
	update_gages()

func _on_DISSUB_demated(mate_seal):
	xfer_seal = mate_seal
	update_gages()

func _on_RescueSub_saved(crew_rem, _full_rv):
	dissub.diss_rem_setter(crew_rem) 
	crew_savedg = crew_sizeg - crew_rem
	GlobalData.saves_set(GlobalData.saves_get() + 1)
	GlobalData.score_set(GlobalData.saves_get() * 10)
	xferaudio.play()
	update_gages()

func _on_RescueSub_rv_state_changed(state):
	$rescuequeery.rvstate_set(state)
	print("audio controller in game gen fired. == ", state)
	if state == 0 or state == 1:
		surfsnd.play()
	else:
		surfsnd.stop()

	if state == 2 or state == 3:
		var modchk = (sort_track+1)%2
		if modchk == 0:
			deepsnd1.play()
		else:
			deepsnd2.play()
	else:
		deepsnd1.stop()
		deepsnd2.stop()


func _update_sortie_num(new_value, _new_bool):
	sort_track = new_value
	
func _format_seconds(time : float, use_milliseconds : bool) -> String:
	var minutes := time / 60
	var seconds := fmod(time, 60)
	if not use_milliseconds:
		return "%02d:%02d" % [minutes, seconds]
	var milliseconds := fmod(time, 1) * 100
	return "%02d:%02d:%02d" % [minutes, seconds, milliseconds]
