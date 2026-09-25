## A hurtbox class for hit detection. Emits a signal when a hitbox collides with it.
class_name Hurtbox
extends Area3D

signal on_hit ## A signal used to broadcast when this hurtbox is hit.

func _ready() -> void:
	monitoring = false

## Called from a hitbox when it hits this hurtbox.
func recieve_hit() -> void:
	on_hit.emit()
