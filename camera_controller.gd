class_name CameraController extends Node3D

# Export Vars
@export var position_smoothing: float = 0.2 ## Percent of player movement camera position catches up to per frame.
@export var rotation_smoothing: float = 0.2 ## Percent of player rotation camera rotation catches up to per frame.

# Onready Vars
@onready var target := $".."
@onready var camera := $Camera3D

func _physics_process(_delta: float) -> void:
	position = lerp(position, target.global_position, position_smoothing)
	rotation.y = lerp_angle(rotation.y, target.global_rotation.y, rotation_smoothing)
