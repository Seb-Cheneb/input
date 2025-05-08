@icon("./input.png")
class_name InputHandler
extends Node

# Singleton instance
static var instance: InputHandler = null

# Command invoker
var invoker: CommandInvoker

# The actor/player reference
var player_ref = null

# Input mappings - action name to command object
var input_mappings = {}

# Input configuration
var input_config = {
	"move_left": {"type": "key", "key": KEY_A, "gamepad": JOY_AXIS_LEFT_X, "gamepad_direction": -1},
	"move_right": {"type": "key", "key": KEY_D, "gamepad": JOY_AXIS_LEFT_X, "gamepad_direction": 1},
	"move_up": {"type": "key", "key": KEY_W, "gamepad": JOY_AXIS_LEFT_Y, "gamepad_direction": -1},
	"move_down": {"type": "key", "key": KEY_S, "gamepad": JOY_AXIS_LEFT_Y, "gamepad_direction": 1},
	"jump": {"type": "key", "key": KEY_SPACE, "gamepad": JOY_BUTTON_A},
	"attack": {"type": "key", "key": KEY_E, "gamepad": JOY_BUTTON_X},
	"undo": {"type": "key", "key": KEY_Z, "gamepad": JOY_BUTTON_Y},
	"redo": {"type": "key", "key": KEY_Y, "gamepad": JOY_BUTTON_B}
}

# Detect input devices
var using_gamepad = false
var gamepad_deadzone = 0.3

func _init():
	# Set up singleton pattern
	if instance == null:
		instance = self
	else:
		printerr("InputHandler already exists!")
		
func _ready():
	# Create command invoker
	invoker = CommandInvoker.new()
	add_child(invoker)
	
	# Setup input mapping
	_setup_input_actions()

# Setup input actions in the input map
func _setup_input_actions():
	# Clear existing actions
	for action in InputMap.get_actions():
		if action.begins_with("input_"):
			InputMap.erase_action(action)
	
	# Set up actions based on config
	for action_name in input_config:
		var action_id = "input_" + action_name
		var config = input_config[action_name]
		
		# Create action if it doesn't exist
		if not InputMap.has_action(action_id):
			InputMap.add_action(action_id)
		
		# Add keyboard event
		if config.has("key"):
			var event = InputEventKey.new()
			event.keycode = config["key"]
			InputMap.action_add_event(action_id, event)
		
		# Add gamepad button event
		if config.has("gamepad") and config["type"] == "key":
			var event = InputEventJoypadButton.new()
			event.button_index = config["gamepad"]
			InputMap.action_add_event(action_id, event)

# Set player reference
func set_player(player):
	player_ref = player

# Process input every frame
func _process(delta):
	# Detect if gamepad is being used
	for joy_id in range(Input.get_connected_joypads().size()):
		if Input.is_joy_known(joy_id):
			var any_button_pressed = false
			for button in range(JOY_BUTTON_MAX):
				if Input.is_joy_button_pressed(joy_id, button):
					any_button_pressed = true
					break
					
			var any_axis_moved = false
			for axis in range(JOY_AXIS_MAX):
				if abs(Input.get_joy_axis(joy_id, axis)) > gamepad_deadzone:
					any_axis_moved = true
					break
					
			if any_button_pressed or any_axis_moved:
				using_gamepad = true
				break
	
	# Check for keyboard input
	if Input.is_key_pressed(KEY_ANY):
		using_gamepad = false
	
	# Process input actions
	_process_movement()
	_process_actions()

# Process movement input
func _process_movement():
	if player_ref == null:
		return
		
	var move_dir = Vector2.ZERO
	
	# Handle keyboard movement
	if not using_gamepad:
		if Input.is_action_pressed("input_move_left"):
			move_dir.x -= 1
		if Input.is_action_pressed("input_move_right"):
			move_dir.x += 1
		if Input.is_action_pressed("input_move_up"):
			move_dir.y -= 1
		if Input.is_action_pressed("input_move_down"):
			move_dir.y += 1
	else:
		# Handle gamepad movement
		var joy_id = 0
		var x_axis = Input.get_joy_axis(joy_id, JOY_AXIS_LEFT_X)
		var y_axis = Input.get_joy_axis(joy_id, JOY_AXIS_LEFT_Y)
		
		if abs(x_axis) > gamepad_deadzone:
			move_dir.x = x_axis
		if abs(y_axis) > gamepad_deadzone:
			move_dir.y = y_axis
	
	# Normalize movement vector
	if move_dir.length() > 0:
		move_dir = move_dir.normalized()
		var move_command = MoveCommand.new(player_ref, move_dir)
		invoker.execute_command(move_command)

# Process action input (jump, attack, etc.)
func _process_actions():
	if player_ref == null:
		return
		
	# Handle jump
	if Input.is_action_just_pressed("input_jump"):
		var jump_command = JumpCommand.new(player_ref)
		invoker.execute_command(jump_command)
	
	# Handle attack
	if Input.is_action_just_pressed("input_attack"):
		var attack_command = AttackCommand.new(player_ref)
		invoker.execute_command(attack_command)
	
	# Handle undo
	if Input.is_action_just_pressed("input_undo"):
		invoker.undo_last_command()
	
	# Handle redo
	if Input.is_action_just_pressed("input_redo"):
		invoker.redo_last_command()

# Rebind an action to a new key
func rebind_action(action_name: String, key_code: int) -> void:
	if input_config.has(action_name):
		input_config[action_name]["key"] = key_code
		
		# Update the InputMap
		var action_id = "input_" + action_name
		
		# Remove old keyboard events
		var events = InputMap.action_get_events(action_id)
		for event in events:
			if event is InputEventKey:
				InputMap.action_erase_event(action_id, event)
		
		# Add new keyboard event
		var new_event = InputEventKey.new()
		new_event.keycode = key_code
		InputMap.action_add_event(action_id, new_event)
		
		print("Action " + action_name + " rebound to key " + str(key_code))

# Rebind a gamepad button
func rebind_gamepad_button(action_name: String, button_index: int) -> void:
	if input_config.has(action_name) and input_config[action_name]["type"] == "key":
		input_config[action_name]["gamepad"] = button_index
		
		# Update the InputMap
		var action_id = "input_" + action_name
		
		# Remove old gamepad events
		var events = InputMap.action_get_events(action_id)
		for event in events:
			if event is InputEventJoypadButton:
				InputMap.action_erase_event(action_id, event)
		
		# Add new gamepad event
		var new_event = InputEventJoypadButton.new()
		new_event.button_index = button_index
		InputMap.action_add_event(action_id, new_event)
		
		print("Action " + action_name + " rebound to gamepad button " + str(button_index))

# Save input configuration to a file
func save_input_config(path: String = "user://input_config.json") -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	if file:
		var json_string = JSON.stringify(input_config)
		file.store_string(json_string)
		print("Input configuration saved to " + path)
	else:
		printerr("Failed to save input configuration")

# Load input configuration from a file
func load_input_config(path: String = "user://input_config.json") -> bool:
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			var json = JSON.new()
			var error = json.parse(json_string)
			if error == OK:
				var data = json.get_data()
				if typeof(data) == TYPE_DICTIONARY:
					input_config = data
					_setup_input_actions()
					print("Input configuration loaded from " + path)
					return true
	
	print("Failed to load input configuration")
	return false
