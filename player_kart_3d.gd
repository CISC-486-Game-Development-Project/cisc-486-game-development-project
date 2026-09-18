class_name PlayerKart3D extends CharacterBody3D

# Export Vars
@export_category("Stats")
@export_group("Driving")
@export_custom(PROPERTY_HINT_NONE, "suffix:m/s") var top_speed: float ## Defines the top speed.
@export_custom(PROPERTY_HINT_NONE, "suffix:m/s") var top_reverse_speed: float ## Defines the top speed when reversing.
@export_custom(PROPERTY_HINT_NONE, "suffix:m/s/s") var acceleration: float ## Defines the rate of acceleration.
@export_custom(PROPERTY_HINT_NONE, "suffix:m/s") var boost_speed: float  ## Defines the top speed when boosting.
@export_custom(PROPERTY_HINT_NONE, "suffix:m/s/s") var boost_acceleration: float ## Defines the rate of acceleration when boosting.
@export var roll_friction: float = 0.8 ## Defines the intensity of the friction acting against the forward momentum.

@export_group("Steering")
@export_custom(PROPERTY_HINT_NONE, "suffix:degrees") var max_steering_angle_slow: float = 16.0
@export_custom(PROPERTY_HINT_NONE, "suffix:degrees") var max_steering_angle_fast: float = 8.0
@export_custom(PROPERTY_HINT_NONE, "suffix:degrees/s") var handbrake_steering_velocity: float = 45.0
@export_custom(PROPERTY_HINT_NONE, "suffix:degrees/s") var air_steering_velocity: float = 50.0
@export_custom(PROPERTY_HINT_NONE, "suffix:m") var wheel_base: float = 1.5
@export var drift_steering_multiplier: float = 1.5

# Onready Vars
@onready var kart_mesh: MeshInstance3D = $MeshInstance3D
@onready var camera_controller: CameraController = $CameraController
@onready var debug_label_3d: Label3D = $DebugLabel3D

# Internal Vars
var move_input: Vector2
var steer_request: float
var accel_request: float
var break_request: bool
var drift_request: bool
var drift_dir_request: int
var steering: float

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit() # Debug Exit Game
	
	## Step 1: Handle Input
	_handle_input()
	
	## Step 2: Handle Movement
	_handle_driving(delta)
	_handle_steering(delta)
	move_and_slide()
	
	# Debug label above kart
	var drift_dir_text: String = ""
	if drift_dir_request != 0:
		drift_dir_text = "left" if drift_dir_request < 0 else "right"
	debug_label_3d.text = "Velocity: " + str(roundf(velocity.length() * 10) / 10) + "\nDrifting: " + str(drift_request) + " " + drift_dir_text

## Called every physics frame to collect input data.
func _handle_input() -> void:
	move_input = Input.get_vector("Left", "Right", "Backward", "Forward")
	
	# Set movement requests based on input
	steer_request = move_input.x
	accel_request = move_input.y
	break_request = Input.is_action_pressed("Backward")
	
	if steer_request != 0: # Prevents neutral drifting (TODO: no it doesn't)
		drift_request = Input.is_action_pressed("Drift")
	
	# Set drift direction on press, reset on release
	if Input.is_action_just_pressed("Drift"):
		drift_dir_request = sign(steer_request)
	if Input.is_action_just_released("Drift"):
		drift_dir_request = 0

## Called every physics frame to apply driving forces.
func _handle_driving(delta: float) -> void:
	var forward: Vector3 = -global_transform.basis.z;
	var horizontal_velocity: Vector3 = get_horizontal_velocity()
	
	# Apply Drag
	horizontal_velocity = horizontal_velocity.lerp(Vector3.ZERO, 1 - pow(0.5, roll_friction * delta))
	
	var speed = horizontal_velocity.length()
	horizontal_velocity = forward * forward.dot(horizontal_velocity)
	
	if accel_request > 0 and speed < top_speed: # Handle acceleration
		horizontal_velocity += accel_request * forward * delta * acceleration
	elif accel_request < 0 and speed < top_reverse_speed: # Handle backwards acceleration
		horizontal_velocity += accel_request * forward * delta * acceleration
	
	velocity = horizontal_velocity + Vector3.UP * velocity.y # Apply horizontal and vertical velocity

## Called every physics frame to apply steering forces.
func _handle_steering(delta: float) -> void:
	var v: Vector3 = get_horizontal_velocity()
	var horizonal_speed: float = v.length() * sign(v.dot(-global_transform.basis.z))
	steering = lerp(steering, steer_request, 1.0 - pow(0.5, 60.0 * delta))
	
	var angular_velocity: float = 0.0
	
	var max_steering_angle = lerp(max_steering_angle_slow, max_steering_angle_fast, clamp(horizonal_speed / top_speed, 0.0, 1.0))
	var avg_steering_angle = lerp(max_steering_angle_slow, max_steering_angle_fast, 1.0)
	
	if break_request && abs(horizonal_speed) < 1:
		angular_velocity = deg_to_rad(handbrake_steering_velocity * steering)
	else:
		var steering_angle: float
		if drift_request:
			steering_angle = drift_steering_multiplier * max_steering_angle * (drift_dir_request * 0.6 + 0.4 * steering)
		elif abs(horizonal_speed) > 0.01:
			steering_angle = max_steering_angle * steering
		angular_velocity = (horizonal_speed * tan(deg_to_rad(steering_angle))) / wheel_base
	
	rotate_y(-delta * angular_velocity)
	
	# Visually move
	kart_mesh.rotation.z = steering * 0.5 * deg_to_rad(avg_steering_angle)

## Returns the horizontal velocity of the player as a Vector3 with y always set to 0.
func get_horizontal_velocity() -> Vector3:
	return Vector3(velocity.x, 0, velocity.z)
