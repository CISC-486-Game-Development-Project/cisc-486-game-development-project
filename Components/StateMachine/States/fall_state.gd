class_name FallState
extends State

# Export Vars
@export_group("Physics Parameters")
@export var fall_velocity: float = -100.0 ## Speed of falling.
@export var fall_gravity: float = 20.0 ## Intensity of gravitational force.

# Onready Vars
@onready var entity: CharacterBody3D = state_machine.get_parent()

func enter(prev_state: State) -> void:
	if prev_state is DriveState:
		entity.trick_coyote_timer.start()
	
	# Begin state's unique animation here

func physics_update(delta: float) -> void:
	# Handle fall movement
	entity.velocity.y = move_toward(entity.velocity.y, fall_velocity, fall_gravity * delta)
	
	check_transitions()
