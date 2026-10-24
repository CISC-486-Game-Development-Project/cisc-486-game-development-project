class_name DriftState
extends State

# Onready Vars
@onready var entity: CharacterBody3D = state_machine.get_parent()

# Internal Vars
var drift_time: float
var drift_level: int

func enter(_prev_state: State) -> void:
	entity.drift_dir = sign(entity.steer_request)
	drift_time = 0
	drift_level = 0
	entity.drift_particles.emitting = true
	
	# Begin state's unique animation here

func exit(_next_state: State) -> void:
	if entity.get_horizontal_velocity().length() > entity.drift_speed_threshold: # No boost if too slow or in offroad
		# Apply turbo boost
		match drift_level:
			1: entity.set_boost(Boost.new(entity.short_turbo_boost_time))
			2: entity.set_boost(Boost.new(entity.mid_turbo_boost_time))
			3: entity.set_boost(Boost.new(entity.long_turbo_boost_time))
	
	# Reset vars
	entity.drift_dir = 0
	drift_time = 0
	drift_level = 0
	entity.drift_particles.emitting = false

func update(delta: float) -> void:
	# Fast charge if holding above threshold in drift direction
	if abs(entity.steer_request) >= entity.fast_charge_threshold and sign(entity.steer_request) == entity.drift_dir:
		drift_time += delta * entity.fast_charge_multiplier
	else:
		drift_time += delta
	
	if drift_time < entity.short_turbo_charge_time:
		drift_level = 0
		entity.drift_particles.process_material.color = Color(0.3, 0.3, 0.3, 1.0)
	elif drift_time >= entity.short_turbo_charge_time and drift_time < entity.mid_turbo_charge_time:
		drift_level = 1
		entity.drift_particles.process_material.color = Color(1.0, 1.0, 0.0, 1.0)
	elif drift_time >= entity.mid_turbo_charge_time and drift_time < entity.long_turbo_charge_time:
		drift_level = 2
		entity.drift_particles.process_material.color = Color(1.0, 0.45, 0.0, 1.0)
	elif drift_time >= entity.long_turbo_charge_time:
		drift_level = 3
		entity.drift_particles.process_material.color = Color(1.0, 0.0, 0.0, 1.0)

func physics_update(delta: float) -> void:
	# Handle fall movement
	entity.velocity.y = move_toward(entity.velocity.y, entity.fall_velocity, entity.fall_gravity * delta)
	
	check_transitions()
