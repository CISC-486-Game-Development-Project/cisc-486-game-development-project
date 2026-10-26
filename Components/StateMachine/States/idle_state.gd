class_name IdleState
extends State

# Onready Vars
@onready var entity: CharacterBody3D = state_machine.get_parent()

func physics_update(_delta: float) -> void:
	check_transitions()
