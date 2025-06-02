@icon("./input.png")
class_name InputController extends Node

@export var _actor: Node3D

var _action_to_command: Dictionary = {}


func _ready() -> void:
	_action_to_command = {
		"left": MoveLeftCommand.new(_actor)
	}
