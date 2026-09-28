class_name Launchable
extends Node

# Export Vars
@export var hitbox: Hitbox
@export var rigid_body_3d: RigidBody3D

func _ready() -> void:
	if hitbox and rigid_body_3d:
		hitbox.on_hit.connect(_on_hit.bind())

func _on_hit(area: Area3D) -> void:
	var hitter = area.owner
	if hitter is Kart3D:
		rigid_body_3d.apply_central_impulse(hitter.velocity * 2 + Vector3(0, hitter.velocity.length() / 2, 0))
