class_name DriveState
extends State

# Onready Vars
@onready var entity: CharacterBody3D = state_machine.get_parent()

func enter(_prev_state: State) -> void:
	pass # Begin state's unique animation here

func physics_update(_delta: float) -> void:
	check_transitions()
