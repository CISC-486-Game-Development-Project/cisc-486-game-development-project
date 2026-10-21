class_name ThrowableItem
extends Item

const SPAWN_DISTANCE: float = 5.0 ## The horizontal distance from the kart that throwable item entities spawn.

func use(kart: Kart3D) -> void:
	# Add item entity to world
	var new_item := entity.instantiate()
	kart.get_tree().current_scene.add_child(new_item)
	
	new_item.rotation.y = kart.rotation.y
	new_item.global_position = kart.global_position + -kart.global_basis.z * SPAWN_DISTANCE + kart.global_basis.y
