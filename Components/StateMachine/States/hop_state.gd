class_name HopState
extends State

# Export Vars
@export_group("Physics Parameters")
@export var hop_velocity: float = 10.0 ## Velocity impulse when hopping.
@export var hop_deceleration: float = 100.0 ## How quickly the hop decelerates from the impulse.

# Onready Vars
@onready var entity: CharacterBody3D = state_machine.get_parent()

func enter(_prev_state: State) -> void:
	# Add impulse velocity when hop begins
	entity.velocity.y = hop_velocity
	
	# Begin state's unique animation here

func exit(_next_state: State) -> void:
	# Ensure end of hop has 0 velocity
	entity.velocity.y = 0

func physics_update(delta: float) -> void:
	# Handle hop movement and deceleration
	entity.velocity.y = move_toward(entity.velocity.y, 0, hop_deceleration * delta)
	
	check_transitions()
