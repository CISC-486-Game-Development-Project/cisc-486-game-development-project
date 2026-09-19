class_name TrickState
extends State

# Export Vars
@export var trick_boost_time: float = 1.0

@export_group("Physics Parameters")
@export var trick_hop_velocity: float = 10.0 ## Velocity impulse when hopping.
@export var trick_hop_deceleration: float = 100.0 ## How quickly the hop decelerates from the impulse.

# Onready Vars
@onready var entity: CharacterBody3D = state_machine.get_parent()

func enter(_prev_state: State) -> void:
	# Add impulse velocity when hop begins
	entity.velocity.y = trick_hop_velocity
	
	# Begin state's unique animation here
	_play_trick_effect()

func exit(_next_state: State) -> void:
	# Ensure end of hop has 0 velocity
	entity.velocity.y = 0
	
	# Queue boost for when the ground is hit
	entity.queue_ground_boost(trick_boost_time)

func physics_update(delta: float) -> void:
	# Handle hop movement and deceleration
	entity.velocity.y = move_toward(entity.velocity.y, 0, trick_hop_deceleration * delta)
	
	check_transitions()

func _play_trick_effect():
	entity.trick_particles.restart()
