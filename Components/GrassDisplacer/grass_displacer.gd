## Component for adding the parent node to the grass_displacers group so it's position and radius can effect the grass shader.
class_name GrassDisplacer
extends Node

# Export Vars
@export var radius: float = 1.5

func _ready() -> void:
	get_parent().add_to_group("grass_displacers") # Add to grass_displacers group
	get_parent().set_meta("displace_radius", radius) # Set displace_radius meta tag to radius
