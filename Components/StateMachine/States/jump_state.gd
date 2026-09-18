class_name JumpState
extends State

func enter(_prev_state: State) -> void:
	pass # Begin state's unique animation here

func physics_update(_delta: float) -> void:
	check_transitions()
