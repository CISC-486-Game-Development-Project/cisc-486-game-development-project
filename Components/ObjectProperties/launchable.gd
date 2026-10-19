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
		# Launch object (hitter.global_position is close enough to work, switch to an integrate_forces() implementation for more accurate collision point detection)
		rigid_body_3d.apply_impulse(hitter.velocity + Vector3(0, hitter.velocity.length() / 2, 0), hitter.global_position - rigid_body_3d.global_position)
