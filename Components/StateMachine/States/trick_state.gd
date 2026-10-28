class_name TrickState
extends State

# Onready Vars
@onready var entity: CharacterBody3D = state_machine.get_parent()

func enter(_prev_state: State) -> void:
	# Add impulse velocity when hop begins
	entity.velocity.y = entity.trick_hop_velocity
	
	# Start trick cooldown
	entity.trick_cooldown_timer.start()
	
	# Reset trick combo if timer has run out
	if not entity.trick_combo_timer.time_left > 0:
		entity.trick_combo_level = 0
	
	# Begin state's unique animation here
	_play_trick_effect()

func exit(_next_state: State) -> void:
	# Ensure end of hop has 0 velocity
	entity.velocity.y = 0
	
	# Start combo timer
	entity.trick_combo_timer.start()
	
	# Queue boost for when the ground is hit
	entity.queue_ground_boost(Boost.new(entity.trick_boost_time * (1 + (clampi(entity.trick_combo_level - 1, 0, 5) * entity.trick_boost_combo_multiplier))))

func physics_update(delta: float) -> void:
	# Handle hop movement and deceleration
	entity.velocity.y = move_toward(entity.velocity.y, 0, entity.trick_hop_deceleration * delta)
	
	check_transitions()

func _play_trick_effect() -> void:
	# Play one shot trick particles
	entity.trick_particles.restart()
	
	# Handle SFX based on combo
	if entity.trick_combo_level == 0:
		entity.trick_combo_level += 1
	elif entity.trick_combo_timer.time_left > 0:
		entity.trick_combo_level += 1
	if entity is Kart3D and entity.is_player:
		AudioManager.create_sound(entity.trick_sfx[clampi(entity.trick_combo_level, 0, len(entity.trick_sfx) - 1)])
	
	# Play random trick animation based on direction 
	if entity.animation_player.current_animation:
		entity.animation_player.stop() # Stop existing animation to prevent no animation playing
	if entity.steer_request > 0.2: # Right Trick
		entity.animation_player.play("trick_anim_right_2")
	elif entity.steer_request < -0.2: # Left Trick
		entity.animation_player.play("trick_anim_left_2")
	elif entity.pitch_request > 0.2: # Forward Trick
		entity.animation_player.play("trick_anim_forward")
	elif entity.pitch_request < -0.2: # Backward Trick
		entity.animation_player.play("trick_anim_backward")
	else: # Neutral Trick
		match randi_range(0, 1):
			0: entity.animation_player.play("trick_anim_right_2")
			1: entity.animation_player.play("trick_anim_left_2")
