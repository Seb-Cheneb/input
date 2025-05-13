extends Node

var config_file = "res://configs/keybinds.cfg"

func save_keybinds():
	var config = ConfigFile.new()
	
	for action in InputMap.get_actions():
		var events = InputMap.action_get_events(action)
		# Save all events as an array
		config.set_value("keybinds", action, events)
	
	config.save(config_file)

func load_keybinds():
	var config = ConfigFile.new()
	var err = config.load(config_file)
	
	if err == OK:
		for action in InputMap.get_actions():
			if config.has_section_key("keybinds", action):
				InputMap.action_erase_events(action)
				var events = config.get_value("keybinds", action)
				for event in events:
					InputMap.action_add_event(action, event)

func rebind_action(action: String, event: InputEvent, index: int = 0):
	var events = InputMap.action_get_events(action)
	# If index exists, replace that binding, otherwise add new one
	if index < events.size():
		events[index] = event
		InputMap.action_erase_events(action)
		for e in events:
			InputMap.action_add_event(action, e)
	else:
		InputMap.action_add_event(action, event)
	save_keybinds()
