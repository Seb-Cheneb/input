@icon("./input.png")
class_name InputController extends Node


@export var _actor: Node3D
var _action_list: Dictionary = {}


func _ready() -> void:
	_action_list = {
		"left": MoveLeftCommand.new(_actor)
	}


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventAction:
		return

	if event.pressed && event.action in _action_list:
			_action_list[event.action].execute()
