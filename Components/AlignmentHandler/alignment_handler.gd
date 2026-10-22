class_name AlignmentHandler
extends Node

@export var align_model: bool
@export var align_collision: bool

@export var body: Node3D
@export var model: Node3D
@export var collision_shape_3d: CollisionShape3D
@export var ground_ray_cast_3d: RayCast3D
@export var ray_length: float = 1.0

func _physics_process(delta: float) -> void:
	_align_to_ground(delta)

## Called every physics frame to align the model with the angle of the ground.
func _align_to_ground(delta: float) -> void:
	if body.is_on_floor() and ground_ray_cast_3d.is_colliding():
		_align_to_normal(ground_ray_cast_3d.get_collision_normal(), delta)
	elif body.is_on_floor():
		_align_to_normal(Vector3.UP, delta)
	else:
		_set_ray_direction(Vector3.DOWN)

## Helper function for aligning a transform with the y of a normal vector.
func _align_with_y(xform: Transform3D, new_y: Vector3) -> Transform3D:
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform

## Sets the ground ray cast to point in a specific direction.
func _set_ray_direction(global_dir: Vector3) -> void:
	var local_dir := ground_ray_cast_3d.global_transform.basis.inverse() * global_dir.normalized()
	ground_ray_cast_3d.target_position = local_dir * ray_length

## Aligns the model and/or collision to the given normal over time. Should be called every physics frame.
func _align_to_normal(n: Vector3, delta: float) -> void:
	if align_model:
			var xform = _align_with_y(model.global_transform, n)
			model.global_transform = model.global_transform.interpolate_with(xform, 12 * delta)
	if align_collision:
		collision_shape_3d.global_transform = model.global_transform
	_set_ray_direction(-n)
