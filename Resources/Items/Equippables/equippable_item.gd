class_name EquippableItem
extends Item

func use(kart: Kart3D) -> void:
	# Add item entity to world
	var new_item := entity.instantiate()
	kart.add_child(new_item)
