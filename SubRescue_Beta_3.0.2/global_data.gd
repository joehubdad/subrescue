## global_data.gd
extends Node

class_name globals
	
## Global data singleton script - save recent game scores or saves (max 10? slots),
## save high saves.

## Later add audio functionality ????
var high_score: int setget score_set, score_get
var career_souls: int setget saves_set, saves_get
var rv_capacity: int setget rvcap_set, rvcap_get


func _ready():
	globals_init()
	rv_init()

func score_set(new_value):
	high_score = new_value

	
func score_get():
	return high_score
	
func saves_set(new_value):
	career_souls = new_value

func saves_get():
	return career_souls

#func save():
#	var data = {
#		"high_saves" : high_value,
#		"previous" : prev_save
#	}
#
#	var file = File.new()
#	file.open("user://savegame.json", File.WRITE)
#	var json = to_json(data)
#	file.store_line(json)
#	file.close()

func rvcap_set(new_value):
	rv_capacity = new_value

func rvcap_get():
	return rv_capacity

# Admin function to establish initial game values
func globals_init():
	self.score_set(0)
	self.saves_set(0)

func rv_init():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var nom_rv_cap: int = 20
	var rvcap = round(nom_rv_cap + rng.randi_range(-4, 4))
	rvcap = int(rvcap)
	rvcap_set(rvcap)
		
