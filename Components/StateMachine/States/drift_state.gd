class_name DriftState
extends State

# Export Vars
@export_category("Charge Times")
@export var short_turbo_charge_time: float = 1.0
@export var mid_turbo_charge_time: float = 2.0
@export var long_turbo_charge_time: float = 3.0

@export_category("Boost Times")
@export var short_turbo_boost_time: float = 1.0
@export var mid_turbo_boost_time: float = 2.0
@export var long_turbo_boost_time: float = 3.0

@export var drift_particles: GPUParticles3D

# Onready Vars
@onready var entity: CharacterBody3D = state_machine.get_parent()

# Internal Vars
var drift_time: float
var drift_level: int

func enter(_prev_state: State) -> void:
	entity.drift_dir = sign(entity.steer_request)
	drift_time = 0
	drift_level = 0
	drift_particles.emitting = true
	
	# Begin state's unique animation here

func exit(_next_state: State) -> void:
	# Apply turbo boost
	match drift_level:
		1: entity.set_boost(short_turbo_boost_time)
		2: entity.set_boost(mid_turbo_boost_time)
		3: entity.set_boost(long_turbo_boost_time)
	
	# Reset vars
	entity.drift_dir = 0
	drift_time = 0
	drift_level = 0
	drift_particles.emitting = false

func update(delta: float) -> void:
	drift_time += delta
	if drift_time < short_turbo_charge_time:
		drift_level = 0
		drift_particles.process_material.color = Color(0.3, 0.3, 0.3, 1.0)
	elif drift_time >= short_turbo_charge_time and drift_time < mid_turbo_charge_time:
		drift_level = 1
		drift_particles.process_material.color = Color(1.0, 1.0, 0.0, 1.0)
	elif drift_time >= mid_turbo_charge_time and drift_time < long_turbo_charge_time:
		drift_level = 2
		drift_particles.process_material.color = Color(1.0, 0.45, 0.0, 1.0)
	elif drift_time >= long_turbo_charge_time:
		drift_level = 3
		drift_particles.process_material.color = Color(1.0, 0.0, 0.0, 1.0)

func physics_update(_delta: float) -> void:
	check_transitions()
