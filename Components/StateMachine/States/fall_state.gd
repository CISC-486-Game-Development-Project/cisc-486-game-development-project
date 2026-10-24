class_name FallState
extends State

# Onready Vars
@onready var entity: CharacterBody3D = state_machine.get_parent()

func enter(prev_state: State) -> void:
	if prev_state is DriveState:
		entity.trick_coyote_timer.start()
	
	# Begin state's unique animation here

func physics_update(delta: float) -> void:
	# Handle fall movement
	entity.velocity.y = move_toward(entity.velocity.y, entity.fall_velocity, entity.fall_gravity * delta)
	
	check_transitions()
