class_name AirTrickState
extends State

# Export Vars
@export var trick_boost_time: float = 1.0 ## Duration of boost gained from this trick.
@export var trick_boost_combo_multiplier: float = 0.1 ## Added to boost multiplier for each trick in the combo beyond the first.
@export var directional_trick_intensity: float = 10.0 ## The intensity of the rotation applied when air tricking in a direction.

# Onready Vars
@onready var entity: CharacterBody3D = state_machine.get_parent()

func enter(_prev_state: State) -> void:
	# Rotate in the direction of steering
	entity.rotate_y(deg_to_rad(directional_trick_intensity * -entity.steer_request))

	# Start trick cooldown
	entity.trick_cooldown_timer.start()
	
	# Begin state's unique animation here
	_play_trick_effect()

func exit(_next_state: State) -> void:
	# Start combo timer
	entity.trick_combo_timer.start()
	
	# Queue boost for when the ground is hit
	entity.queue_ground_boost(trick_boost_time * (1 + ((entity.trick_combo_level - 1) * trick_boost_combo_multiplier)))

func physics_update(_delta: float) -> void:
	check_transitions()

func _play_trick_effect() -> void:
	# Play one shot trick particles
	entity.trick_particles.restart()
	
	# Handle SFX based on combo
	if entity.trick_combo_level == 0:
		entity.trick_combo_level += 1
	elif entity.trick_combo_timer.time_left > 0:
		entity.trick_combo_level += 1
	AudioManager.create_sound(entity.trick_sfx[clampi(entity.trick_combo_level, 0, len(entity.trick_sfx) - 1)])
	
	# Play random trick animation
	match randi_range(0, 2):
		0: entity.animation_player.play("trick_anim_1")
		1: entity.animation_player.play("trick_anim_2")
		2: entity.animation_player.play("trick_anim_3")
