## A component for providing camera movement functionality.
class_name CameraController extends Node3D

# Export Vars
@export var position_smoothing: float = 0.4 ## Percent of player movement camera position catches up to per frame.
@export var rotation_smoothing: float = 0.2 ## Percent of player rotation camera rotation catches up to per frame.
@export var rotation_multiplier: float = 2.0 ## Multiplier for camera_request based movement.

# Onready Vars
@onready var target := $".." ## The follow target of the camera.

# Internal Vars
var is_following_kart: bool = true

func _physics_process(delta: float) -> void:
	# Handle camera movement in physics process to avoid jitter
	if target is Kart3D:
		_handle_kart_camera(delta)
	else:
		_handle_camera()

func _handle_camera() -> void:
	position = lerp(position, target.global_position, position_smoothing)
	rotation.y = lerp_angle(rotation.y, target.global_rotation.y, rotation_smoothing)

func _handle_kart_camera(delta: float) -> void:
	position = lerp(position, target.global_position, position_smoothing)
	
	# Go back to following kart if acceleration pressed
	if target.accel_request != 0.0:
		is_following_kart = true
	
	# Move camera if camera_request, otherwise do normal camera movements
	if target.camera_request != Vector2.ZERO:
		is_following_kart = false
		rotation.y += target.camera_request.x * rotation_multiplier * delta
		rotation.x += target.camera_request.y * rotation_multiplier * delta
	elif is_following_kart:
		rotation.y = lerp_angle(rotation.y, target.global_rotation.y, rotation_smoothing)
		rotation.x = lerp_angle(rotation.x, 0, rotation_smoothing)
