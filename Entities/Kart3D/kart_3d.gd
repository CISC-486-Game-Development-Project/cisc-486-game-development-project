class_name Kart3D
extends CharacterBody3D

# Export Vars
@export_category("Functionality")
@export var kart_stats: KartStats ## The stats that define the kart.
@export var input_handler: InputHandler ## The input handler for controlling the kart.

@export_group("Driving")
@export_custom(PROPERTY_HINT_NONE, "suffix:m/s") var top_speed: float ## Defines the top speed.
@export_custom(PROPERTY_HINT_NONE, "suffix:m/s") var top_reverse_speed: float ## Defines the top speed when reversing.
@export_custom(PROPERTY_HINT_NONE, "suffix:m/s/s") var acceleration: float ## Defines the rate of acceleration.
@export_custom(PROPERTY_HINT_NONE, "suffix:m/s") var boost_speed: float  ## Defines the top speed when boosting.
@export_custom(PROPERTY_HINT_NONE, "suffix:m/s/s") var boost_acceleration: float ## Defines the rate of acceleration when boosting.
@export var roll_friction: float = 0.8 ## Defines the intensity of the friction acting against the forward momentum.
@export var trick_speed_threshold: float = 10.0 ## Defines the minimum speed required to trick while driving.

@export_group("Steering")
@export_custom(PROPERTY_HINT_NONE, "suffix:degrees") var max_steering_angle_slow: float = 10.0 ## Defines the maximum steering angle, should be higher when going slow.
@export_custom(PROPERTY_HINT_NONE, "suffix:degrees") var max_steering_angle_fast: float = 5.0 ## Defines the maximum steering angle, should be lower when going fast.
@export_custom(PROPERTY_HINT_NONE, "suffix:degrees/s") var handbrake_steering_velocity: float = 45.0 ## Defines the speed of handbrake steering (turning while very slow).
@export_custom(PROPERTY_HINT_NONE, "suffix:degrees/s") var air_steering_velocity: float = 40.0 ## Defines the speed of mid-air steering.
@export_custom(PROPERTY_HINT_NONE, "suffix:m") var wheel_base: float = 1.5 ## The diameter of the wheels.
@export var drift_steering_multiplier: float = 1.2 ## The factor by which steer direction is multiplied while drifting.

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

@onready var debug_kart: KartModel = $KartModel/AnimationPivot/DebugKart
@onready var debug_label_3d: Label3D = $DebugLabel3D

# Internal Vars
var wheels: Array[Wheel] ## The array of Wheel objects attaced to this kart.
var hurtbox: Hurtbox ## The hurtbox of this kart.

var steer_request: float ## Steering intensity request to be set by an input_manager.
var pitch_request: float ## Pitch intensity request to be set by an input_manager. (Entirely aesthetic)
var accel_request: float ## Acceleration intensity request to be set by an input_manager.
var brake_request: bool ## Brake request to be set by an input_manager.
var hop_request: bool ## Hop request to be set by an input_manager.
var drift_request: bool ## Drift request to be set by an input_manager.
var drift_dir: int ## The direction of a currently active drift. 1 = right, 0 = none, -1 = left.
var camera_request: Vector2 ## The vector for camera movement to be set by an input_manager.
var item_request: bool ## Call to use stored item set by an input_manager.

var steering: float ## The intensity of the current steering.
var offroad_factor: float ## The intensity of the current offroad factor.
var ignore_offroad_timer: float ## Determines whether speed calculations should ignore offroad currently.
var boost_timer: float ## The time left in the current boost.
var boost_queue: Array[Boost] ## The queue of boosts to be applied once the ground is hit.

var is_hit: bool ## True when the kart is hit.

var trick_combo_level: int ## Number of tricks currently comboed.

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
		hurtbox = kart.hurtbox
		hurtbox.reparent(self)
		hurtbox.on_hit.connect(hit)
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
		_handle_item()
	_align_to_ground(delta)
	move_and_slide()
	
	# Update Debug Label
	_update_debug_label()

## Called every physics frame to collect input data.
func _handle_input() -> void:
	# Set movement requests based on input
	steer_request = Input.get_axis("Left", "Right")
	accel_request = Input.get_axis("Backward", "Forward")
	brake_request = Input.is_action_pressed("Backward")
	hop_request = Input.is_action_just_pressed("Drift")
	drift_request = Input.is_action_pressed("Drift")
	item_request = Input.is_action_just_pressed("Item")

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
	
	# Bounce off walls
	if is_on_wall():
		_wall_bump()
	
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
	
	var max_steering_angle = lerp(max_steering_angle_slow, max_steering_angle_fast, clamp(horizonal_speed / top_speed, 0.0, 1.0))
	var avg_steering_angle = lerp(max_steering_angle_slow, max_steering_angle_fast, 1.0)
	
	# Calculate angular_velocity when not mid-air
	if is_on_floor():
		if brake_request && abs(horizonal_speed) < 1:
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

## Called every physics frame to align the kart with the angle of the ground.
func _align_to_ground(delta: float) -> void:
	if is_on_floor():
		var n = ground_ray_cast_3d.get_collision_normal()
		var xform = _align_with_y(kart_model.global_transform, n)
		kart_model.global_transform = kart_model.global_transform.interpolate_with(xform, 12 * delta)

## Helper function for aligning a transform with the y of a normal vector.
func _align_with_y(xform: Transform3D, new_y: Vector3) -> Transform3D:
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform

## Bounces off walls. Should be called when wall is hit.
func _wall_bump() -> void:
	pass # TODO: Implement bumping off walls like MKWorld

## Calculates the current offroad_factor based on terrain conditions.
func recalculate_offroad_factor() -> void:
	# Ignore offroad factor if timer running
	if ignore_offroad_timer > 0.0:
		if offroad_factor != 0.0:
			offroad_factor = 0.0
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
func hit(hitter: Node, velocity_reduction_factor: float = 0.4, vertical_velocity_impulse: float = 3.0) -> void:
	# Boost panel hit logic
	if hitter is BoostPanel:
		queue_ground_boost(hitter.boost)
	
	# Normal hit logic
	else:
		if not is_hit: # Apply velocity effects if just hit
			velocity *= velocity_reduction_factor
			velocity.y += vertical_velocity_impulse
		is_hit = true

####################
## Item Functions ##
####################

func _handle_item() -> void:
	if item_request:
		print("Item Used!")

#######################
## Getters & Setters ##
#######################

## Returns the horizontal velocity of the player as a Vector3 with y always set to 0.
func get_horizontal_velocity() -> Vector3:
	return Vector3(velocity.x, 0, velocity.z)

## Sets the stats of the kart based on kart stats and current terrain conditions.
func set_stats() -> void:
	## Stat Formulae
	# Speed
	top_speed = (20.0 + (kart_stats.base_speed / 2)) * (1 - offroad_factor)
	top_reverse_speed = (8.0 + (kart_stats.base_speed / 2)) * (1 - offroad_factor)
	
	# Acceleration
	acceleration = (12.0 + (kart_stats.base_acceleration * 2)) * (1 - offroad_factor)
	
	# Boost
	boost_speed = (top_speed * 1.5) + (kart_stats.base_boost * 1.5)
	
	# Handling
	max_steering_angle_slow = 8.0 + (kart_stats.base_handling / 2)
	max_steering_angle_fast = 3.0 + (kart_stats.base_handling / 2)
	handbrake_steering_velocity = 45.0 + kart_stats.base_handling
	air_steering_velocity = 40.0 + kart_stats.base_handling

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
		if hop_request and trick_coyote_timer.time_left > 0 and not ground_ray_cast_3d.is_colliding():
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
	# Define debug texts to display
	var debugs: Array[String] = [
		"Velocity: " + str(roundf(velocity.length() * 10) / 10),
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
