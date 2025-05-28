@icon("./input.png")
class_name KeybindsManager extends RefCounted

# Signal emitted when an action is performed
signal action_performed(action_name)

# Dictionary that maps action names to their corresponding input events
# Format: { "action_name": [InputEvent, InputEvent, ...], ... }
var _action_bindings = {}

# Dictionary to store default bindings for reset functionality
var _default_bindings = {}

# Dictionary to track if an action was just released (to prevent holding)
var _just_released = {}

# Constructor
func _init():
	# Initialize with empty dictionaries
	_action_bindings = {}
	_default_bindings = {}
	_just_released = {}

# Called when the node enters the scene tree
func _ready():
	# Store all the project's predefined input actions as defaults
	_load_project_actions()

# Process input
func _input(event):
	if not event.is_pressed() and event is InputEventKey:
		# Mark keys as released
		for action_name in _action_bindings.keys():
			for bound_event in _action_bindings[action_name]:
				if bound_event is InputEventKey and bound_event.keycode == event.keycode:
					_just_released[action_name] = true
	
	if event.is_pressed():
		# Check if this event matches any of our bindings
		for action_name in _action_bindings.keys():
			for bound_event in _action_bindings[action_name]:
				if _events_match(event, bound_event):
					# Prevent key holding - only trigger if the key was just released before
					if event is InputEventKey:
						if _just_released.get(action_name, true):
							_just_released[action_name] = false
							emit_signal("action_performed", action_name)
					else:
						# For non-key events, just emit the signal
						emit_signal("action_performed", action_name)

# Register a new action with its default keybinding
func register_action(action_name: String, default_event: InputEvent) -> void:
	if not _action_bindings.has(action_name):
		_action_bindings[action_name] = [default_event]
		_default_bindings[action_name] = [default_event.duplicate()]
	else:
		_action_bindings[action_name].append(default_event)
		_default_bindings[action_name].append(default_event.duplicate())

# Add a keybinding to an existing action
func add_keybinding(action_name: String, event: InputEvent) -> bool:
	if not _action_bindings.has(action_name):
		_action_bindings[action_name] = [event]
		return true
	
	# Check if this binding already exists
	for existing_event in _action_bindings[action_name]:
		if _events_match(existing_event, event):
			return false
	
	_action_bindings[action_name].append(event)
	return true

# Remove a specific keybinding from an action
func remove_keybinding(action_name: String, event: InputEvent) -> bool:
	if not _action_bindings.has(action_name):
		return false
	
	var events = _action_bindings[action_name]
	for i in range(events.size()):
		if _events_match(events[i], event):
			events.remove_at(i)
			return true
	
	return false

# Replace all keybindings for an action
func set_keybindings(action_name: String, events: Array) -> bool:
	if not _action_bindings.has(action_name):
		return false
	
	_action_bindings[action_name] = events
	return true

# Get all keybindings for an action
func get_keybindings(action_name: String) -> Array:
	if not _action_bindings.has(action_name):
		return []
	
	return _action_bindings[action_name]

# Check if an action exists
func has_action(action_name: String) -> bool:
	return _action_bindings.has(action_name)

# Reset bindings for a specific action to defaults
func reset_to_default(action_name: String) -> bool:
	if not _default_bindings.has(action_name):
		return false
	
	var default_copy = []
	for event in _default_bindings[action_name]:
		default_copy.append(event.duplicate())
	
	_action_bindings[action_name] = default_copy
	return true

# Reset all bindings to defaults
func reset_all_to_default() -> void:
	for action_name in _default_bindings.keys():
		reset_to_default(action_name)

# Load from a dictionary (useful for saving/loading)
func load_from_dict(data: Dictionary) -> void:
	_action_bindings.clear()
	
	for action_name in data.keys():
		var events = []
		for event_dict in data[action_name]:
			var event = _dict_to_input_event(event_dict)
			if event:
				events.append(event)
		
		if events.size() > 0:
			_action_bindings[action_name] = events

# Save to a dictionary (useful for saving/loading)
func save_to_dict() -> Dictionary:
	var data = {}
	
	for action_name in _action_bindings.keys():
		data[action_name] = []
		for event in _action_bindings[action_name]:
			var event_dict = _input_event_to_dict(event)
			if not event_dict.is_empty():
				data[action_name].append(event_dict)
	
	return data

# Save bindings to a file
func save_to_file(file_path: String) -> bool:
	var data = save_to_dict()
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		return false
	
	file.store_string(JSON.stringify(data))
	return true

# Load bindings from a file
func load_from_file(file_path: String) -> bool:
	if not FileAccess.file_exists(file_path):
		return false
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return false
	
	var json_text = file.get_as_text()
	var json = JSON.new()
	var error = json.parse(json_text)
	
	if error != OK:
		return false
	
	var data = json.get_data()
	load_from_dict(data)
	return true

# Check if two InputEvents match based on their type
func _events_match(event1: InputEvent, event2: InputEvent) -> bool:
	if event1.get_class() != event2.get_class():
		return false
	
	# Handle different event types
	if event1 is InputEventKey:
		return event1.keycode == event2.keycode
	elif event1 is InputEventMouseButton:
		return event1.button_index == event2.button_index
	elif event1 is InputEventJoypadButton:
		return event1.button_index == event2.button_index
	elif event1 is InputEventJoypadMotion:
		return event1.axis == event2.axis and event1.axis_value == event2.axis_value
	
	return false

# Helper function to convert InputEvent to Dictionary
func _input_event_to_dict(event: InputEvent) -> Dictionary:
	var dict = {}
	
	if event is InputEventKey:
		dict["type"] = "key"
		dict["keycode"] = event.keycode
	elif event is InputEventMouseButton:
		dict["type"] = "mouse_button"
		dict["button_index"] = event.button_index
	elif event is InputEventJoypadButton:
		dict["type"] = "joypad_button"
		dict["button_index"] = event.button_index
		dict["device"] = event.device
	elif event is InputEventJoypadMotion:
		dict["type"] = "joypad_motion"
		dict["axis"] = event.axis
		dict["axis_value"] = event.axis_value
		dict["device"] = event.device
	
	return dict

# Helper function to convert Dictionary to InputEvent
func _dict_to_input_event(dict: Dictionary) -> InputEvent:
	var event = null
	
	match dict.get("type", ""):
		"key":
			event = InputEventKey.new()
			event.keycode = dict["keycode"]
			event.pressed = true
		
		"mouse_button":
			event = InputEventMouseButton.new()
			event.button_index = dict["button_index"]
			event.pressed = true
		
		"joypad_button":
			event = InputEventJoypadButton.new()
			event.button_index = dict["button_index"]
			event.device = dict.get("device", 0)
			event.pressed = true
		
		"joypad_motion":
			event = InputEventJoypadMotion.new()
			event.axis = dict["axis"]
			event.axis_value = dict["axis_value"]
			event.device = dict.get("device", 0)
	
	return event

# Load all predefined project actions as defaults
func _load_project_actions() -> void:
	var actions = InputMap.get_actions()
	
	for action_name in actions:
		var events = InputMap.action_get_events(action_name)
		if events.size() > 0:
			_action_bindings[action_name] = []
			_default_bindings[action_name] = []
			
			for event in events:
				_action_bindings[action_name].append(event.duplicate())
				_default_bindings[action_name].append(event.duplicate())
