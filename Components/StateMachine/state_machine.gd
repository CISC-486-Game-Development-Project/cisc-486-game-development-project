class_name StateMachine
extends Node

# Export Vars
@export var initial_state: State ## Determines the state the [class StateMachine] will be initialized with.

# Internal Vars
var current_state: State

func _ready() -> void:
	# Start with initial state
	if initial_state:
		change_state(initial_state)

func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

## Handles changing the [member current_state], as well as calling [method State.exit] on the previous state and [method State.enter] on the new state.
func change_state(new_state: State) -> void:
	var prev_state = current_state
	
	# Call exit on previous state
	if current_state:
		current_state.exit(new_state)
	
	# Set state
	current_state = new_state
	
	# Call enter on new state
	if current_state:
		current_state.enter(prev_state)
