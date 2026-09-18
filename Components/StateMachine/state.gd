class_name State
extends Node

# Internal Vars
@onready var state_machine: StateMachine = get_parent() ## Reference to the [StateMachine] this state is a part of.
@onready var state_transitons: Array[Node] = get_children() ## Reference to the [StateTransition] children of this state.

# Virtual methods that child states can override
@warning_ignore_start("unused_parameter")

## Should be called for code to run when state is entered.
func enter(_prev_state: State) -> void:
	pass

## Should be called for code to run when state is exited.
func exit(_next_state: State) -> void:
	pass

## Should be called for code to run each frame while in state.
func update(_delta: float) -> void:
	pass

## Should be called for code to run each physics frame while in state.
func physics_update(_delta: float) -> void:
	pass

## Checks conditions of all [member state_transitions] and changes state if a condition is true.
## Should be called each frame in either [method update] or [method physics_update] for state change conditions to be checked.
func check_transitions() -> void:
	for transition in state_transitons:
		if transition.condition_met():
			state_machine.change_state(transition.to_state)
