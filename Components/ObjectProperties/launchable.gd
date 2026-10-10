class_name Launchable
extends Node

# Export Vars
@export var hitbox: Hitbox
@export var rigid_body_3d: RigidBody3D

func _ready() -> void:
	# Bind hitbox signal if set up properly
	if hitbox and rigid_body_3d:
		hitbox.on_hit.connect(_on_hit.bind())

## Called when the hitbox is hit.
func _on_hit(area: Area3D) -> void:
	var hitter = area.get_parent()
	
	if hitter is Kart3D:
		# Launch object
		rigid_body_3d.apply_central_impulse(hitter.velocity * 2 + Vector3(0, hitter.velocity.length() / 2, 0))
		rigid_body_3d.angular_velocity += Vector3(randf_range(0, 10), randf_range(0, 10), randf_range(0, 10))
