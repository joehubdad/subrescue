# Inputtester.gd .....script to show a list of all assigned input map keys/actions
extends Node2D

#		Started with the below convoluted line of code...
#		print("key pressed ", OS.get_scancode_string(one_list[0].get_scancode_with_modifiers()))

var game_input_dict = {}   ## A large dictionary with all actions as keys and action commands as values
var dict_key = ""   ## The name of the action
var dict_value = []  ## An array of action commands

func _ready():
	run_me()

func run_me():

	var the_actions = InputMap.get_actions()
	print(the_actions)
	
	for anaction in range(0, the_actions.size()):
		var one_list = InputMap.get_action_list(the_actions[anaction])
#		var key_code = [""]
		var temp_code = ""
		for tau in range(0,one_list.size()):
#			temp_code = String(one_list[tau]+temp_code)
			if one_list[tau] is InputEventKey:
				temp_code = String(temp_code + " and " + one_list[tau].as_text() + " key")
				print(temp_code)
#				key_code[tau] = temp_code
			elif one_list[tau] is InputEventJoypadButton:
				temp_code = String(temp_code + " and " + OS.get_scancode_string(one_list[tau].get_button_index()) + " button")
				print(temp_code)
#				key_code[tau] = temp_code
			elif one_list[tau] is InputEventJoypadMotion:
				temp_code = String(temp_code + " and " + OS.get_scancode_string(one_list[tau].get_axis()) + " joystick")
				print(temp_code)
#				key_code[tau] = temp_code

		game_input_dict[the_actions[anaction]] = temp_code
	save_control_list()


func save_control_list():
	var save_controls = File.new()
	save_controls.open("user://controlssave.save", File.WRITE)
	save_controls.store_line(to_json(game_input_dict))
	save_controls.close()
