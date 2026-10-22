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
	
	#TODO: FIX THIS NOW THAT HITBOX IS INSIDE KARTMODEL
	# Launch object (hitter.global_position is close enough to work, switch to an integrate_forces() implementation for more accurate collision point detection)
	if hitter is CharacterBody3D or hitter is RigidBody3D:
		rigid_body_3d.apply_impulse(hitter.velocity + Vector3(0, hitter.velocity.length() / 2, 0), hitter.global_position - rigid_body_3d.global_position)
	elif hitter.get_parent() is CharacterBody3D or hitter.get_parent() is RigidBody3D:
		var hitter_body = hitter.get_parent()
		rigid_body_3d.apply_impulse(hitter_body.velocity + Vector3(0, hitter_body.velocity.length() / 2, 0), hitter_body.global_position - rigid_body_3d.global_position)
