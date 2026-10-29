class_name StartState
extends State

# Onready Vars
@onready var entity: CharacterBody3D = state_machine.get_parent()

# Internal Vars
var is_ready: bool ## When true, leave this state.

func enter(_prev_state: State) -> void:
	# If Kart3D, set can_drive to false
	if entity is Kart3D:
		if entity.can_drive:
			entity.can_drive = false
	
	is_ready = false
	RaceManager.race_started.connect(func(): is_ready = true)

func exit(_next_state: State) -> void:
	# If Kart3D, set can_drive to true
	if entity is Kart3D:
		if not entity.can_drive:
			entity.can_drive = true

func physics_update(delta: float) -> void:
	# Handle fall movement
	entity.velocity.y = move_toward(entity.velocity.y, entity.fall_velocity, entity.fall_gravity * delta)
	
	check_transitions()
