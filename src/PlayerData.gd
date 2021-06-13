extends Node

var _SAVE_KEY = "player_data"

var _data = {}


func _init():
	add_to_group("persistent")
	_do_create_new()
	
func _do_create_new():
	_data["current_level"] = 0
	_data["unlocked_level"] = 0
	_data["next_screen"] = "game"

func reset():
	_do_create_new()
	
func get(key):
	return _data[key]
	
func set(key, value):
	_data[key] = value
	SaveManager.do_save()

func completeCurrentLevel():
	_data["current_level"] = _data["current_level"] + 1
	_data["unlocked_level"] = max(_data["current_level"], _data["unlocked_level"])
	SaveManager.do_save()
	
func do_save():
	var save_data = {}
	
	# save misc data
	save_data["data"] = _data.duplicate(true)
	return save_data
	
func do_load(save_data : Dictionary):
	_do_create_new()
	_data = save_data["data"].duplicate(true)
