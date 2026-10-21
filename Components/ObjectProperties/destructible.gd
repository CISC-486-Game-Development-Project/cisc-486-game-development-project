class_name Destructible
extends Node

# Export Vars
@export var hitbox: Hitbox ## The hitbox used for detecting hits.
@export var to_break: Node3D ## The object to be broken.
@export var breaking_time: float ## The time it takes after being hit for this object to despawn.
@export var break_particles: GPUParticles3D ## The particles to play when breaking.

func _ready() -> void:
	# Bind hitbox signal if set up properly
	if hitbox and to_break:
		hitbox.on_hit.connect(_on_hit.bind())

## Called when the hitbox is hit.
func _on_hit(_area: Area3D) -> void:
	#var hitter = area.get_parent()
	
	# Destroy after breaking_time
	get_tree().create_timer(breaking_time).timeout.connect(_destroy)
	
	# Play break_particles effect if it exists
	if break_particles:
		break_particles.lifetime = breaking_time / 2
		break_particles.top_level = true # Set top level so particles don't move if object launches
		break_particles.restart()

## Called when to_break should be destroyed.
func _destroy() -> void:
	# Shrink, then free
	var size_tween: Tween = create_tween()
	size_tween.tween_property(to_break, "scale", Vector3.ONE/100, 0.1)
	size_tween.finished.connect(to_break.queue_free)
