@icon("./input.png")
extends Node

var _current_keybindings = "res://configs/keybinds.cfg"
var _original_keybindings = "res://configs/original_keybindings.cfg"
var _keybindings: Array[Keybind] = []


func _ready():
	# Call this once on the first run or if the file does not exist
	if not FileAccess.file_exists(_original_keybindings):
		save_original_keybinds()


func save_keybinds():
	var config = ConfigFile.new()

	for keybind in _keybindings:
		config.set_value("keybinds", keybind.action, keybind.events)
		
	config.save(_current_keybindings)


func save_original_keybinds():
	var config = ConfigFile.new()

	for action in InputMap.get_actions():
		var keybind: Keybind = Keybind.new()
		keybind.action = action
		keybind.events = InputMap.action_get_events(action)
		
		# store keybindings object
		_keybindings.append(keybind)
		
		# save new keybinding
		config.set_value("keybinds", keybind.action, keybind.events)

	config.save(_original_keybindings)


func load_keybinds():
	var config = ConfigFile.new()
	var err = config.load(_current_keybindings)

	if err == OK:
		for action in InputMap.get_actions():
			if config.has_section_key("keybinds", action):
				InputMap.action_erase_events(action)
				var events = config.get_value("keybinds", action)
				for event in events:
					InputMap.action_add_event(action, event)


func reset_keybindings() -> void:
	var config = ConfigFile.new()
	var err = config.load(_original_keybindings)

	if err == OK:
		for action in InputMap.get_actions():
			if config.has_section_key("keybinds", action):
				InputMap.action_erase_events(action)
				var events = config.get_value("keybinds", action)
				for event in events:
					InputMap.action_add_event(action, event)
		save_keybinds()  # Optionally update current config to match the reset


func rebind_action(action: String, event: InputEvent, index: int = 0):
	var events = InputMap.action_get_events(action)

	if index < events.size():
		events[index] = event
		InputMap.action_erase_events(action)
		for e in events:
			InputMap.action_add_event(action, e)
	else:
		InputMap.action_add_event(action, event)

	save_keybinds()
