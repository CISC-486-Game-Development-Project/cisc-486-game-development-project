## Abstract class for handling inputs from some unspecified source.
class_name InputHandler
extends Node

var kart: Kart3D ## Kart to set input requests for. Should be set by the kart this node is attached to on ready.

## Should be called every frame or physics frame to collect input data.
func handle_input() -> void:
	pass
