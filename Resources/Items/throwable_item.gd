class_name ThrowableItem
extends Item

const SPAWN_DISTANCE: float = 5.0 ## The horizontal distance from the kart that throwable item entities spawn.

func use(kart: Kart3D) -> void:
	# Add item entity to world
	var new_item := entity.instantiate()
	kart.get_tree().current_scene.add_child(new_item)
	
	# Send backward if holding back beyond deadzone, otherwise send forward
	var dir: int = -1 if kart.pitch_request > 0.2 else 1
	
	# Rotation matches kart facing direction (or inverse), position in front of kart (or behind)
	new_item.rotation.y = kart.rotation.y * dir
	new_item.global_position = kart.global_position + (-kart.global_basis.z * SPAWN_DISTANCE * dir) + kart.global_basis.y
