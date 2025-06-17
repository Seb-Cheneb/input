@icon("./input.png")
class_name InputController 
extends Node


@export_category("Debugging")
@export var is_debugging: bool = false

var current_input_direction: Vector2 = Vector2.ZERO
var input_direction: Vector2 = Vector2.ZERO
var input_vector: Vector3 = Vector3.ZERO


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	get_input_vector()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


## gets the ground movement input direction and updates the input vector
func get_input_vector():
	current_input_direction = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	if not current_input_direction.is_equal_approx(input_direction):
		input_direction = current_input_direction
		input_vector = Vector3(input_direction.x, 0, input_direction.y).normalized()
		Logger.info(is_debugging, self, "new input vector detected: " + str(input_vector))


#@export var _actor: Node3D
#var _action_list: Dictionary = {}


# func _ready() -> void:
# 	# _action_list = {
# 	# 	"left": MoveLeftCommand.new(_actor)
# 	# }


#func _unhandled_input(event: InputEvent) -> void:
	#if not event is InputEventAction:
		#return
#
	#if event.pressed && event.action in _action_list:
			#_action_list[event.action].execute()
