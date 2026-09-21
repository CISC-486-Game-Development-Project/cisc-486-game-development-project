class_name DestructibleObject
extends RigidBody3D

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body == self:
		return
	
	if body is CharacterBody3D:
		apply_central_impulse(body.velocity * 2 + Vector3(0, body.velocity.length() / 2, 0))
	elif body is RigidBody3D:
		pass
