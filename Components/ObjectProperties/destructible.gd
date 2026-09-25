class_name Destructible
extends Node

# Export Vars
@export var hitbox: Hitbox ## The hitbox used for detecting hits.
@export var to_break: Node3D ## The object to be broken.
@export var breaking_time: float ## The time it takes after being hit for this object to despawn.

func _ready() -> void:
	if hitbox and to_break:
		hitbox.on_hit.connect(_on_hit.bind())

func _on_hit(area: Area3D) -> void:
	var hitter = area.owner
	if hitter is PlayerKart3D:
		get_tree().create_timer(breaking_time).timeout.connect(to_break.queue_free)
