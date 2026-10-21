## A component for providing camera movement functionality.
class_name CameraController extends Node3D

# Export Vars
@export var target: Node3D ## The follow target of the camera.
@export var position_smoothing: float = 0.4 ## Percent of player movement camera position catches up to per frame.
@export var rotation_smoothing: float = 0.2 ## Percent of player rotation camera rotation catches up to per frame.
@export var rotation_multiplier: float = 2.0 ## Multiplier for camera_request based movement.

# Onready Vars
@onready var arm: SpringArm3D = $SpringArm3D

# Internal Vars
var is_following_kart: bool = true

func _ready() -> void:
	# Stop the arm from hitting the target.
	if target is CollisionObject3D:
		arm.add_excluded_object(target.get_rid())

func _physics_process(delta: float) -> void:
	# Handle camera movement in physics process to avoid jitter
	if target is Kart3D:
		_handle_kart_camera(delta)
	else:
		_handle_camera()

func _handle_camera() -> void:
	# Smooth follow position and rotation
	global_position = lerp(global_position, target.global_position, position_smoothing)
	global_rotation.y = lerp_angle(global_rotation.y, target.global_rotation.y, rotation_smoothing)

func _handle_kart_camera(delta: float) -> void:
	# Always smooth follow position
	global_position = lerp(global_position, target.global_position, position_smoothing)
	
	# Flip camera when reverse_camera_request, otherwise return to normal
	if target.reverse_camera_request and arm.rotation_degrees.y != 180.0:
		arm.rotation_degrees.y = 180.0
	elif not target.reverse_camera_request and arm.rotation_degrees.y != 0.0:
		arm.rotation_degrees.y = 0.0
	
	# Go back to following kart if acceleration pressed
	if target.accel_request != 0.0:
		is_following_kart = true
	
	# Move camera if camera_request, otherwise do normal camera movements
	if target.camera_request != Vector2.ZERO:
		is_following_kart = false
		global_rotation.y += -target.camera_request.x * rotation_multiplier * delta
		global_rotation.x += target.camera_request.y * rotation_multiplier * delta
		global_rotation_degrees.x = clampf(global_rotation_degrees.x, -45, 45)
	elif is_following_kart:
		global_rotation.y = lerp_angle(global_rotation.y, target.global_rotation.y, rotation_smoothing)
		global_rotation.x = lerp_angle(global_rotation.x, 0, rotation_smoothing)
