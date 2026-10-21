class_name ConsumableItem
extends Item

func use(kart: Kart3D) -> void:
	# Add item entity to world
	var new_item := entity.instantiate()
	kart.add_child(new_item)
	
	# Consume item entity
	if new_item.has_method("consume"):
		new_item.consume(kart)
	new_item.queue_free()
