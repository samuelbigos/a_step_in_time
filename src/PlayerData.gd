extends Node

var _SAVE_KEY = "player_data"

var _data = {}

enum LevelState {
	Locked,
	Unlocked,
	Skipped,
	Complete
}

func _init():
	add_to_group("persistent")
	_do_create_new()
	
func _do_create_new():
	_data["current_level"] = 0
	_data["furthest_level"] = 0
	_data["level_state"] = []
	for i in range(100):
		_data["level_state"].append(LevelState.Locked)
	_data["level_state"][0] = 1
	_data["keys"] = 3
	_data["next_screen"] = "game"

func reset():
	_do_create_new()
	
func get(key):
	return _data[key]
	
func set(key, value):
	_data[key] = value
	SaveManager.do_save()

func completeCurrentLevel():
	if _data["level_state"][_data["current_level"]] == LevelState.Skipped:
		_data["keys"] += 1
		
	_data["level_state"][_data["current_level"]] = LevelState.Complete
	_data["current_level"] = _data["current_level"] + 1
	
	if _data["level_state"][_data["current_level"]] == LevelState.Locked:
		_data["level_state"][_data["current_level"]] = LevelState.Unlocked
		
	_data["furthest_level"] = max(_data["furthest_level"], _data["current_level"])
	
	SaveManager.do_save()
	
func do_save():
	var save_data = {}
	
	# save misc data
	save_data["data"] = _data.duplicate(true)
	return save_data
	
func do_load(save_data : Dictionary):
	_do_create_new()
	#_data = save_data["data"].duplicate(true)
