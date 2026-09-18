class_name DriftState
extends State

# Onready Vars
@onready var entity: CharacterBody3D = state_machine.get_parent()

func enter(_prev_state: State) -> void:
	entity.drift_dir = sign(entity.steer_request)
	
	# Begin state's unique animation here

func exit(_next_state: State) -> void:
	entity.drift_dir = 0

func physics_update(_delta: float) -> void:
	check_transitions()
