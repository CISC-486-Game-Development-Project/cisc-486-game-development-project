class_name InputHandler
extends Node

@export var kart: Kart3D ## Kart to set input requests for.

## Should be called every frame or physics frame to collect input data.
func handle_input() -> void:
	if kart:
		kart.steer_request = Input.get_axis("Left", "Right")
		kart.accel_request = Input.get_axis("Backward", "Forward")
		kart.break_request = Input.is_action_pressed("Backward")
		kart.hop_request = Input.is_action_just_pressed("Drift")
		kart.drift_request = Input.is_action_pressed("Drift")
