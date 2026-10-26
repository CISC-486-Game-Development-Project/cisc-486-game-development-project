class_name Kart3D
extends CharacterBody3D

# Export Vars
@export_category("Functionality")
@export var kart_stats: KartStats ## The stats that define the kart.
@export var input_handler: InputHandler ## The input handler for controlling the kart.

@export_group("Driving")
@export_custom(PROPERTY_HINT_NONE, "suffix:m/s") var base_top_speed: float ## Defines the base top speed.
@export_custom(PROPERTY_HINT_NONE, "suffix:m/s") var base_top_reverse_speed: float ## Defines the base top speed when reversing.
@export_custom(PROPERTY_HINT_NONE, "suffix:m/s/s") var base_acceleration: float ## Defines the base rate of acceleration.
@export_custom(PROPERTY_HINT_NONE, "suffix:m/s/s") var base_boost_acceleration: float ## Defines the base rate of acceleration when boosting.
@export var base_boost_speed_multiplier: float  ## Defines the factor base top speed is multiplied by when boosting.
@export var roll_friction: float = 0.5 ## Defines the intensity of the friction acting against the forward momentum.
@export var trick_speed_threshold: float = 10.0 ## Defines the minimum speed required to trick while driving.
@export var air_trick_speed_threshold: float = 4.0 ## Defines the minimum speed required to air trick while falling.

@export_group("Steering")
@export_custom(PROPERTY_HINT_NONE, "suffix:degrees") var base_max_steering_angle_slow: float ## Defines the base maximum steering angle, should be higher when going slow.
@export_custom(PROPERTY_HINT_NONE, "suffix:degrees") var base_max_steering_angle_fast: float ## Defines the base maximum steering angle, should be lower when going fast.
@export_custom(PROPERTY_HINT_NONE, "suffix:degrees/s") var base_handbrake_steering_velocity: float ## Defines the base speed of handbrake steering (turning while very slow).
@export_custom(PROPERTY_HINT_NONE, "suffix:degrees/s") var base_air_steering_velocity: float ## Defines the base speed of mid-air steering.
@export_custom(PROPERTY_HINT_NONE, "suffix:m") var wheel_base: float = 1.5 ## The diameter of the wheels.
@export var drift_steering_multiplier: float = 1.3 ## The factor by which steer direction is multiplied while drifting.

@export_group("Drifting")
@export var drift_speed_threshold: float = 5.0 ## Speed that must be exceeded for drifting.

@export var base_short_turbo_charge_time: float = 2.0 ## The base time in seconds it takes to charge a short turbo.
@export var base_mid_turbo_charge_time: float = 4.0 ## The base time in seconds it takes to charge a medium turbo.
@export var base_long_turbo_charge_time: float = 6.0 ## The base time in seconds it takes to charge a long turbo.

@export var fast_charge_threshold: float = 0.8 ## The percent threshold of the control stick that begins fast charging.
@export var fast_charge_multiplier: float = 1.5 ## The time multiplier granted by fast charging.

@export var base_short_turbo_boost_time: float = 1.0 ## The base time in seconds a short turbo's boost lasts.
@export var base_mid_turbo_boost_time: float = 2.0 ## The base time in seconds a medium turbo's boost lasts.
@export var base_long_turbo_boost_time: float = 3.0 ## The base time in seconds a long turbo's boost lasts.

@export_group("Wall Bounce")
@export var wall_bounce_strength: float = 0.6 ## The fraction of speed used for bouncing off a wall.
@export var wall_bounce_duration: float = 0.25 ## The number of seconds driving is overridden when bouncing off a wall.

@export_group("Falling")
@export var base_fall_velocity: float = -100.0 ## Base speed of falling.
@export var base_fall_gravity: float = 20.0 ## Base intensity of gravitational force.

@export_group("Hopping")
@export var hop_velocity: float = 10.0 ## Velocity impulse when hopping.
@export var hop_deceleration: float = 100.0 ## How quickly the hop decelerates from the impulse.

@export_group("Tricking")
@export var trick_hop_velocity: float = 10.0 ## Velocity impulse when trick hopping.
@export var trick_hop_deceleration: float = 100.0 ## How quickly the trick hop decelerates from the impulse.

@export var base_trick_boost_time: float = 1.0 ## Base duration of boost gained from this trick.
@export var base_trick_boost_combo_multiplier: float = 0.1 ## Base multiplier added to boost multiplier for each trick in the combo beyond the first.

@export var base_air_trick_boost_time: float = 1.0 ## Base duration of boost gained from this air trick.
@export var base_air_trick_boost_combo_multiplier: float = 0.1 ## Base multiplier added to boost multiplier for each air trick in the combo beyond the first.
@export var base_directional_air_trick_intensity: float = 10.0 ## The base intensity of the rotation applied when air tricking in a direction.

@export_group("Offroad Factors") # How much the kart will be affected by the terrain (top speed and accel.)
@export var offroad_factor_paved: float = 0.0  
@export var offroad_factor_offroad: float = 0.6
@export var offroad_factor_harsh_offroad: float = 0.8    

@export_group("Sound Effects")
@export var trick_sfx: Array[AudioStream] ## SFX that will be played during sequentially comboed tricks.

# Onready Vars
@onready var kart_model: Node3D = $KartModel
@onready var animation_pivot: Node3D = $KartModel/AnimationPivot
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

@onready var state_machine: StateMachine = $MovementStateMachine
@onready var item_handler: ItemHandler = $ItemHandler
@onready var race_handler: RaceHandler = $RaceHandler

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ground_ray_cast_3d: RayCast3D = $GroundRayCast3D
@onready var trick_ray_cast_3d: RayCast3D = $TrickRayCast3D

@onready var boost_particles: GPUParticles3D = $BoostParticles
@onready var drift_particles: GPUParticles3D = $DriftParticles
@onready var trick_particles: GPUParticles3D = $TrickParticles

@onready var trick_coyote_timer: Timer = $TrickCoyoteTimer
@onready var trick_buffer_timer: Timer = $TrickBufferTimer
@onready var trick_cooldown_timer: Timer = $TrickCooldownTimer
@onready var trick_combo_timer: Timer = $TrickComboTimer

@onready var drive_sfx: AudioStreamPlayer3D = $DriveSFX

@onready var debug_kart: KartModel = $KartModel/AnimationPivot/DebugKart
@onready var debug_label_3d: Label3D = $DebugLabel3D

# Internal Vars
# Components
var wheels: Array[Wheel] ## The array of Wheel objects attaced to this kart.
var hitbox: Hitbox ## The hitbox of this kart.

# Stats
var top_speed: float ## Defines the top speed.
var top_reverse_speed: float ## Defines the top speed when reversing.
var boost_speed: float ## Defines the top speed when boosting.

var acceleration: float ## Defines the rate of acceleration.
var boost_acceleration: float ## Defines the rate of acceleration when boosting.

var short_turbo_charge_time: float ## The time in seconds it takes to charge a short turbo.
var mid_turbo_charge_time: float ## The time in seconds it takes to charge a medium turbo.
var long_turbo_charge_time: float ## The time in seconds it takes to charge a long turbo.

var short_turbo_boost_time: float ## The time in seconds a short turbo's boost lasts.
var mid_turbo_boost_time: float ## The time in seconds a medium turbo's boost lasts.
var long_turbo_boost_time: float ## The time in seconds a long turbo's boost lasts.

var trick_boost_time: float ## Duration of boost gained from this trick.
var trick_boost_combo_multiplier: float ## Added to boost multiplier for each trick in the combo beyond the first.
var air_trick_boost_time: float ## Duration of boost gained from this air trick.
var air_trick_boost_combo_multiplier: float ## Added to boost multiplier for each air trick in the combo beyond the first.

var fall_velocity: float ## Speed of falling.
var fall_gravity: float ## Intensity of gravitational force.

var max_steering_angle_slow: float ## Defines the maximum steering angle, should be higher when going slow.
var max_steering_angle_fast: float ## Defines the maximum steering angle, should be lower when going fast.
var handbrake_steering_velocity: float ## Defines the speed of handbrake steering (turning while very slow).
var air_steering_velocity: float ## Defines the speed of mid-air steering.
var directional_air_trick_intensity ## The intensity of the rotation applied when air tricking in a direction.

# Requests
var steer_request: float ## Steering intensity request to be set by an input_manager.
var pitch_request: float ## Pitch intensity request to be set by an input_manager. (Entirely aesthetic)
var accel_request: float ## Acceleration intensity request to be set by an input_manager.
var hop_request: bool ## Hop request to be set by an input_manager.
var drift_request: bool ## Drift request to be set by an input_manager.
var drift_dir: int ## The direction of a currently active drift. 1 = right, 0 = none, -1 = left.
var item_request: bool ## Call to use stored item set by an input_manager.
var camera_request: Vector2 ## The vector for camera movement to be set by an input_manager.
var reverse_camera_request: bool ## Reverse camera request to be set by an input_manager.

# Driving
var steering: float ## The intensity of the current steering.
var offroad_factor: float ## The intensity of the current offroad factor.
var ignore_offroad_timer: float ## Determines whether speed calculations should ignore offroad currently.
var boost_timer: float ## The time left in the current boost.
var boost_queue: Array[Boost] ## The queue of boosts to be applied once the ground is hit.

# Hitting
var is_hit: bool ## True when the kart is hit.

# Tricking
var trick_combo_level: int ## Number of tricks currently comboed.

# Wall Bouncing
var pre_slide_velocity: Vector3 ## The velocity before move_and_slide() is called.
var bounce_velocity: Vector3 ## The velocity of the wall bounce.
var bounce_timer: float ## The duration of the wall bounce.

#######################
## Process Functions ##
#######################

func _ready() -> void:
	# Apply KartStats
	if kart_stats:
		## Kart Model
		# Remove debug model
		debug_kart.queue_free()
		
		# Set up new kart model
		var kart: KartModel = kart_stats.kart_model.instantiate()
		animation_pivot.add_child(kart)
		kart_model.position.y = kart.model_height / 2
		collision_shape_3d.position.y = kart.model_height / 2
		wheels = kart.wheels
		hitbox = kart.hitbox
		hitbox.reparent(self)
		hitbox.on_hit.connect(hit)
		collision_shape_3d.shape = kart.collision_shape_3d.shape
		
		# Set kart's stats
		set_stats()
	
	# Set up input handler
	input_handler.kart = self

func _process(delta: float) -> void:
	# Decrement boost timer when active
	if boost_timer > 0:
		boost_timer -= delta
		if boost_timer <= 0: # Stop particles if boost is over
			boost_particles.emitting = false
	
	# Decrement ignore offroad timer when active
	if ignore_offroad_timer > 0:
		ignore_offroad_timer -= delta
	
	# Calculate offroad factor to apply during physics calculations
	recalculate_offroad_factor()

func _physics_process(delta: float) -> void:
	## Step 1: Handle Input
	input_handler.handle_input()
	
	## Step 2: Handle Movement
	if state_machine.current_state is not HitState:
		_handle_driving(delta)
		_handle_steering(delta)
		_update_trick_ray_cast()
	pre_slide_velocity = velocity
	move_and_slide()
	
	# Handle Constant SFX
	_handle_sfx()
	
	# Update Debug Label
	_update_debug_label()

#######################
## Physics Functions ##
#######################

## Called every physics frame to apply driving forces.
func _handle_driving(delta: float) -> void:
	var forward: Vector3 = -global_transform.basis.z;
	var horizontal_velocity: Vector3 = get_horizontal_velocity()
	
	# Apply queued boosts if on ground
	if is_on_floor():
		if len(boost_queue) >= 1:
			for boost in boost_queue:
				set_boost(boost)
			boost_queue.clear()
	
	# Bounce off walls if on wall and not currently bouncing
	if is_on_wall() and bounce_timer <= 0.0:
		_wall_bump()
	
	# If still bouncing off a wall, handle bounce instead of driving
	if bounce_timer > 0.0:
		bounce_timer -= delta # Decrement timer
		bounce_velocity = lerp(bounce_velocity, Vector3.ZERO, 1 - pow(0.5, 4.0 * delta)) # Ease out of bounce
		velocity = bounce_velocity + Vector3.UP * velocity.y # Set horizontal velocity based on bounce
		return
	
	# Apply drag
	horizontal_velocity = horizontal_velocity.lerp(Vector3.ZERO, 1 - pow(0.5, roll_friction * delta))
	
	var speed = horizontal_velocity.length()
	horizontal_velocity = forward * forward.dot(horizontal_velocity)
	
	# Apply boost acceleration while boost is active
	if boost_timer > 0 && speed < boost_speed:
		horizontal_velocity += forward * delta * boost_acceleration
	
	# Start trick buffer if can't trick yet
	if hop_request and trick_ray_cast_3d.is_colliding():
		trick_buffer_timer.start()
	
	# Handle acceleration for forwards and backwards movement
	if accel_request > 0 and speed < top_speed:
		horizontal_velocity += accel_request * forward * delta * acceleration
	elif accel_request < 0 and speed < top_reverse_speed:
		horizontal_velocity += accel_request * forward * delta * acceleration
	
	velocity = horizontal_velocity + Vector3.UP * velocity.y # Apply horizontal and vertical velocity

## Called every physics frame to apply steering forces.
func _handle_steering(delta: float) -> void:
	var v: Vector3 = get_horizontal_velocity()
	var horizonal_speed: float = v.length() * sign(v.dot(-global_transform.basis.z))
	steering = lerp(steering, steer_request, 1.0 - pow(0.5, 60.0 * delta))
	
	# Default angle to when in mid-air
	var angular_velocity: float = deg_to_rad(air_steering_velocity * steering)
	
	var max_steering_angle = 1.0 / lerpf(1.0 / max_steering_angle_slow, 1.0 / max_steering_angle_fast, pow(maxf(horizonal_speed, 0.0) / top_speed, 1.5))
	var avg_steering_angle = lerp(max_steering_angle_slow, max_steering_angle_fast, 1.0)
	
	# Calculate angular_velocity when not mid-air
	if is_on_floor():
		if (accel_request < 0.0) && abs(horizonal_speed) < 1:
			angular_velocity = deg_to_rad(handbrake_steering_velocity * steering)
		else:
			var steering_angle: float
			if state_machine.current_state is DriftState:
				steering_angle = drift_steering_multiplier * max_steering_angle * (drift_dir * 0.6 + 0.4 * steering)
			elif abs(horizonal_speed) > 0.01:
				steering_angle = max_steering_angle * steering
			angular_velocity = (horizonal_speed * tan(deg_to_rad(steering_angle))) / wheel_base
	
	rotate_y(-delta * angular_velocity)
	
	# Visual movement
	for wheel in wheels:
		wheel.set_steering(-steering * 2.0 * deg_to_rad(avg_steering_angle))
		wheel.speed = horizonal_speed
	kart_model.rotation.z = steering * 0.5 * deg_to_rad(avg_steering_angle)
	if state_machine.current_state is DriftState:
		kart_model.rotation.y = lerp(kart_model.rotation.y, -drift_dir * PI/6, 0.1)
	else:
		kart_model.rotation.y = lerp(kart_model.rotation.y, 0.0, 0.1)

## Bounces off walls. Should be called when wall is hit.
func _wall_bump() -> void:
	# Get collision or return if no collision
	var collision: KinematicCollision3D = get_last_slide_collision()
	if collision == null:
		return
	
	# Keep the bounce horizontal so slopes/floors don't launch the kart
	var normal: Vector3 = collision.get_normal()
	normal.y = 0.0 # Ignore vertical component
	if normal.is_zero_approx():
		return # Return if normal ~= zero (no bounce)
	normal = normal.normalized()
	
	var incoming := Vector3(pre_slide_velocity.x, 0.0, pre_slide_velocity.z)
	
	# Only bump if kart was actually moving into the wall
	if incoming.dot(normal) >= 0.0:
		return # Dot product > 0 means vectors are pointing a similar direction, not facing each other, so return
	
	# Set bounce velocity and timer
	bounce_velocity = incoming.bounce(normal) * wall_bounce_strength
	bounce_timer = wall_bounce_duration

## Calculates the current offroad_factor based on terrain conditions.
func recalculate_offroad_factor() -> void:
	# Ignore offroad factor if timer running
	if ignore_offroad_timer > 0.0:
		if offroad_factor != 0.0:
			offroad_factor = 0.0
			set_stats()
		return
	
	# Calculate offroad factor
	var total_offroad_factor: float = 0.0
	var wheels_on_ground: int = 0
	
	if len(wheels) > 0:
		# Check all wheels
		for wheel in wheels:
			var wheel_terrain = wheel.get_wheel_terrain()
			if wheel_terrain:
				wheels_on_ground += 1
				if wheel_terrain.is_in_group("Paved"):
					total_offroad_factor += offroad_factor_paved
				elif wheel_terrain.is_in_group("Offroad"):
					total_offroad_factor += offroad_factor_offroad
				elif wheel_terrain.is_in_group("Harsh Offroad"):
					total_offroad_factor += offroad_factor_harsh_offroad
	else:
		# Check ground raycast if no wheels
		if ground_ray_cast_3d.is_colliding():
			wheels_on_ground = 1
			var ground_terrain = ground_ray_cast_3d.get_collider()
			if ground_terrain.is_in_group("Paved"):
				total_offroad_factor += offroad_factor_paved
			elif ground_terrain.is_in_group("Offroad"):
				total_offroad_factor += offroad_factor_offroad
			elif ground_terrain.is_in_group("Harsh Offroad"):
				total_offroad_factor += offroad_factor_harsh_offroad
	
	# Set offroad_factor if different
	var new_offroad_factor = total_offroad_factor / wheels_on_ground if wheels_on_ground > 0 else 0.0
	if new_offroad_factor != offroad_factor:
		offroad_factor = new_offroad_factor
		set_stats()

## Sets the trick ray cast's position and target position to be relative to the dynamically aligned kart model.
func _update_trick_ray_cast() -> void:
	trick_ray_cast_3d.global_position = kart_model.global_position - kart_model.global_basis.z * 3 + kart_model.global_basis.y
	trick_ray_cast_3d.target_position = trick_ray_cast_3d.global_basis.inverse() * -kart_model.global_basis.y * 3

###########################
## Boost & Hit Functions ##
###########################

## Sets the boost to be active for a set amount of time.
func set_boost(boost: Boost) -> void:
	boost_timer = max(boost_timer, boost.boost_time)
	if boost.ignore_offroad:
		ignore_offroad_timer = max(ignore_offroad_timer, boost.boost_time)
	if boost_timer >= 0:
		boost_particles.emitting = true

## Queues a boost to be set once the ground is hit.
func queue_ground_boost(boost: Boost) -> void:
	boost_queue.append(boost)

## Called when the kart is hit. Sets is_hit variable in order to transition to the HitState.
func hit(hitter_hitbox: Hitbox, velocity_reduction_factor: float = 0.4, vertical_velocity_impulse: float = 3.0) -> void:
	var hitter = hitter_hitbox.get_parent()
	
	# Boost panel hit logic
	if hitter is BoostPanel:
		queue_ground_boost(hitter.boost)
		return
	
	# Do nothing for other karts
	elif hitter is Kart3D:
		return
	
	# Do nothing for trailed items
	elif hitter == item_handler.trailed_item:
		return
	
	# Do nothing for children of self (ex. if an item is equipped)
	elif hitter in self.get_children():
		return
	
	# Normal hit logic
	if not is_hit: # Apply velocity effects if just hit
		velocity *= velocity_reduction_factor
		velocity.y += vertical_velocity_impulse
	is_hit = true

#####################
## Audio Functions ##
#####################

## Handles the pitch and volume of constantly playing kart sound effects.
func _handle_sfx() -> void:
	# Set pitch and volume based on horizontal speed
	# TODO: Hacky way of implementing this, update it to be more dynamic later
	drive_sfx.pitch_scale = remap(get_horizontal_velocity().length(), 0.0, 50.0, 1.0, 2.0)
	drive_sfx.volume_linear = clampf(remap(get_horizontal_velocity().length(), 0.0, 20.0, 0.0, 0.15), 0.0, 0.15)

#######################
## Getters & Setters ##
#######################

## Returns the horizontal velocity of the player as a Vector3 with y always set to 0.
func get_horizontal_velocity() -> Vector3:
	return Vector3(velocity.x, 0, velocity.z)

## Sets the stats of the kart based on kart stats and current terrain conditions.
func set_stats() -> void:
	## Stat Formulae
	var speed_mult: float = 0.8 + 0.1 * kart_stats.base_speed        # 0 = 0.8 | 5 = 1.3
	var accel_mult: float = 0.8 + 0.1 * kart_stats.base_acceleration # 0 = 0.8 | 5 = 1.3
	var boost_mult: float = 0.8 + 0.1 * kart_stats.base_boost        # 0 = 0.8 | 5 = 1.3
	var weight_mult: float = 0.8 + 0.1 * kart_stats.base_weight      # 0 = 0.8 | 5 = 1.3
	var handling_mult: float = 0.8 + 0.1 * kart_stats.base_handling  # 0 = 0.8 | 5 = 1.3
	
	# Speed
	top_speed = base_top_speed * speed_mult * (1 - offroad_factor)
	top_reverse_speed = base_top_reverse_speed * speed_mult * (1 - offroad_factor)
	boost_speed = top_speed * base_boost_speed_multiplier
	
	# Acceleration
	acceleration = base_acceleration * accel_mult * (1 - offroad_factor)
	boost_acceleration = max(base_boost_acceleration, acceleration)
	
	# Stunt Boost
	short_turbo_charge_time = base_short_turbo_charge_time * (1 / boost_mult)
	mid_turbo_charge_time = base_mid_turbo_charge_time * (1 / boost_mult)
	long_turbo_charge_time = base_long_turbo_charge_time * (1 / boost_mult)
	
	short_turbo_boost_time = base_short_turbo_boost_time * boost_mult
	mid_turbo_boost_time = base_mid_turbo_boost_time * boost_mult
	long_turbo_boost_time = base_long_turbo_boost_time * boost_mult
	
	trick_boost_time = base_trick_boost_time * boost_mult
	trick_boost_combo_multiplier = base_trick_boost_combo_multiplier * boost_mult
	air_trick_boost_time = base_air_trick_boost_time * boost_mult
	air_trick_boost_combo_multiplier = base_air_trick_boost_combo_multiplier * boost_mult
	
	# Weight
	fall_velocity = base_fall_velocity * weight_mult
	fall_gravity = base_fall_gravity * weight_mult
	
	# Handling
	max_steering_angle_slow = base_max_steering_angle_slow * handling_mult
	max_steering_angle_fast = base_max_steering_angle_fast * handling_mult
	handbrake_steering_velocity = base_handbrake_steering_velocity * handling_mult
	air_steering_velocity = base_air_steering_velocity * handling_mult
	directional_air_trick_intensity = base_directional_air_trick_intensity * handling_mult

#####################
## Trick Functions ##
#####################

## Returns if a trick is able to occur.
func can_trick() -> bool:
	# Immediate false if cooldown since last trick isn't over
	if trick_cooldown_timer.time_left > 0:
		return false
	
	# False if not above threshold
	if get_horizontal_velocity().length() < trick_speed_threshold:
		return false
	
	# Check logic for tricking depending on current state
	if state_machine.current_state is DriveState:
		if hop_request and not trick_ray_cast_3d.is_colliding():
			#print("Trick Case 1 - Ledge Trick")
			return true
	elif state_machine.current_state is FallState:
		if hop_request and not trick_ray_cast_3d.is_colliding() and trick_coyote_timer.time_left > 0:
			#print("Trick Case 2 - Coyote Fall Trick")
			return true
	elif state_machine.current_state is HopState:
		if trick_buffer_timer.time_left > 0 and not trick_ray_cast_3d.is_colliding():
			#print("Trick Case 3 - Buffered Ledge Trick")
			return true
		elif trick_buffer_timer.time_left > 0 and not ground_ray_cast_3d.is_colliding():
			#print("Trick Case 4 - Buffered Bump Trick")
			return true
	return false

## Returns if an air trick is able to occur.
func can_air_trick() -> bool:
	# Immediate false if cooldown since last trick isn't over
	if trick_cooldown_timer.time_left > 0:
		return false
	
	# Check logic for tricking depending on current state
	if state_machine.current_state is FallState:
		# False if not above threshold (TODO: make air time check instead of this and see if it's better)
		if velocity.length() < air_trick_speed_threshold:
			return false
		
		if hop_request and not ground_ray_cast_3d.is_colliding():
			#print("Air Trick")
			return true
	return false

#####################
## Debug Functions ##
#####################

## Updates the debug label's text with accurate information.
## Should be called every physics frame.
func _update_debug_label() -> void:
	# Return if not visible
	if not debug_label_3d.visible:
		return
	
	# Define debug texts to display
	var debugs: Array[String] = [
		"Top Speed: " + str(roundf(top_speed * 10) / 10),
		"Acceleration: " + str(roundf(acceleration * 10) / 10),
		"Boost Top Speed: " + str(roundf(boost_speed * 10) / 10),
		"Velocity: " + str(roundf(velocity.length() * 10) / 10),
		"Horizontal Speed: " + str (roundf(get_horizontal_velocity().length() * 10) / 10),
		"State: " + state_machine.current_state.name,
		"Drift Direction: " + str(drift_dir),
		"Fast Charge: " + str(abs(steer_request) >= 0.8 and sign(steer_request) == drift_dir),
		"Trick Raycast: " + str(trick_ray_cast_3d.is_colliding()),
		"Ground Raycast: " + str(ground_ray_cast_3d.is_colliding()),
		"Coyote Timer: " + str(trick_coyote_timer.time_left > 0),
		"Buffer Timer: " + str(trick_buffer_timer.time_left > 0),
		"Cooldown Timer: " + str(trick_cooldown_timer.time_left > 0),
		"Trick Combo Timer: " + str(trick_combo_timer.time_left > 0),
		"Trick Combo: " + str(str(trick_combo_level) if trick_combo_level <= 4 else str(trick_combo_level) + " (MAX)"),
		"Boost Time Left: " + str(clamp(round(boost_timer*10)/10, 0, 100)),
		"Ignore Offroad Time Left: " + str(clamp(round(ignore_offroad_timer*10)/10, 0, 100)),
		"Offroad Factor: " + str(offroad_factor),
	]
	
	# Apply debug texts to label
	debug_label_3d.text = ""
	for t in debugs:
		debug_label_3d.text += t + "\n"
