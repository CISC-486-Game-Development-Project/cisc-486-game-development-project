extends Area3D

@export var respawn_time: float = 3

@onready var timer = $Timer

func _on_body_entered(body):
	if visible and body is Kart3D:
		visible = false
		body.item_handler.roll_item()
		timer.start(respawn_time)

func _on_timer_timeout():
	visible = true
