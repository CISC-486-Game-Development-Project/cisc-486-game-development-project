class_name AlignmentHandler
extends Node

@export var body: Node3D
@export var model: Node3D
@export var ground_ray_cast_3d: RayCast3D

func _physics_process(delta: float) -> void:
	_align_to_ground(delta)

## Called every physics frame to align the model with the angle of the ground.
func _align_to_ground(delta: float) -> void:
	if body.is_on_floor():
		var n = ground_ray_cast_3d.get_collision_normal()
		var xform = _align_with_y(model.global_transform, n)
		model.global_transform = model.global_transform.interpolate_with(xform, 12 * delta)
		ground_ray_cast_3d.target_position = -n
	else:
		ground_ray_cast_3d.target_position = Vector3.DOWN

## Helper function for aligning a transform with the y of a normal vector.
func _align_with_y(xform: Transform3D, new_y: Vector3) -> Transform3D:
	xform.basis.y = new_y
	xform.basis.x = -xform.basis.z.cross(new_y)
	xform.basis = xform.basis.orthonormalized()
	return xform
