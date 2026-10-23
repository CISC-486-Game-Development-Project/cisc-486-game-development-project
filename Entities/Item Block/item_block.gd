extends Area3D

func _on_body_entered(body):
	if body is Kart3D:
		body.item_handler.roll_item()
		queue_free()
