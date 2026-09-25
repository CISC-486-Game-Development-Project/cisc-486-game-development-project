class_name DriftState
extends State

# Export Vars
@export_category("Charge Times")
@export var short_turbo_charge_time: float = 2.0 ## The time in seconds it takes to charge a short turbo.
@export var mid_turbo_charge_time: float = 4.0 ## The time in seconds it takes to charge a medium turbo.
@export var long_turbo_charge_time: float = 6.0 ## The time in seconds it takes to charge a long turbo.
@export var fast_charge_threshold: float = 0.8 ## The percent threshold of the control stick that begins fast charging.
@export var fast_charge_multiplier: float = 1.5 ## The time multiplier granted by fast charging.

@export_category("Boost Times")
@export var short_turbo_boost_time: float = 1.0 ## The time in seconds a short turbo's boost lasts.
@export var mid_turbo_boost_time: float = 2.0 ## The time in seconds a medium turbo's boost lasts.
@export var long_turbo_boost_time: float = 3.0 ## The time in seconds a long turbo's boost lasts.

@export_group("Physics Parameters")
@export var fall_velocity: float = -100.0 ## Speed of falling.
@export var fall_gravity: float = 20.0 ## Intensity of gravitational force.

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
	if entity.get_horizontal_velocity().length() > 5: # No boost if too slow
		# Apply turbo boost
		match drift_level:
			1: entity.set_boost(short_turbo_boost_time)
			2: entity.set_boost(mid_turbo_boost_time)
			3: entity.set_boost(long_turbo_boost_time)
	
	# Reset vars
	entity.drift_dir = 0
	drift_time = 0
	drift_level = 0
	entity.drift_particles.emitting = false

func update(delta: float) -> void:
	# Fast charge if holding above threshold in drift direction
	if abs(entity.steer_request) >= fast_charge_threshold and sign(entity.steer_request) == entity.drift_dir:
		drift_time += delta * fast_charge_multiplier
	else:
		drift_time += delta
	
	if drift_time < short_turbo_charge_time:
		drift_level = 0
		entity.drift_particles.process_material.color = Color(0.3, 0.3, 0.3, 1.0)
	elif drift_time >= short_turbo_charge_time and drift_time < mid_turbo_charge_time:
		drift_level = 1
		entity.drift_particles.process_material.color = Color(1.0, 1.0, 0.0, 1.0)
	elif drift_time >= mid_turbo_charge_time and drift_time < long_turbo_charge_time:
		drift_level = 2
		entity.drift_particles.process_material.color = Color(1.0, 0.45, 0.0, 1.0)
	elif drift_time >= long_turbo_charge_time:
		drift_level = 3
		entity.drift_particles.process_material.color = Color(1.0, 0.0, 0.0, 1.0)

func physics_update(delta: float) -> void:
	# Handle fall movement
	entity.velocity.y = move_toward(entity.velocity.y, fall_velocity, fall_gravity * delta)
	
	check_transitions()
