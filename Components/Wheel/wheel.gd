class_name Wheel extends Node3D

# Constants
const RADIAL_SPEED_FACTOR: float = (2 * 0.21 * PI) / 2 * PI

# Export Vars
@export var steering_enabled: bool ## If enabled, wheel can be steered.
@export var steering_intensity: float = 2.0 ## The intensity of the wheel rotation from steering.
@export var spring_length: float = 0.5 ## The length in metres of the spring arm.
@export var wheel_radius: float = 0.5 ## The radius in metres of the wheel.

# Onready Vars
@onready var wheel_visual: Node3D = $WheelVisual
@onready var spring_arm_3d: SpringArm3D = $SpringArm3D
@onready var wheel_pivot: Node3D = $SpringArm3D/WheelPivot
@onready var ray_cast_3d: RayCast3D = $RayCast3D

# Internal Vars
var speed: float = 0.0 ## The current kart speed, set by this wheel's kart parent.

func _ready() -> void:
	spring_arm_3d.spring_length = spring_length

func _process(delta: float) -> void:
	var r = speed * delta * RADIAL_SPEED_FACTOR
	wheel_visual.rotation.z -= r
	
	wheel_visual.position.y = lerp(wheel_visual.position.y, -wheel_pivot.position.z + wheel_radius / 2, 0.1)

## Sets the visual steering of the wheel.
func set_steering(steering: float) -> void:
	if steering_enabled:
		wheel_visual.rotation.y = steering * steering_intensity

## Returns the global position of the visual wheel.
func get_wheel_position() -> Vector3:
	return wheel_visual.global_position

## Returns the terrain this wheel is colliding with.
func get_wheel_terrain() -> Node3D:
	if ray_cast_3d.is_colliding():
		return ray_cast_3d.get_collider()
	else:
		return null
