## Implementation class for handling inputs from a player.
class_name PlayerInputHandler
extends InputHandler

func handle_input() -> void:
	if kart:
		kart.steer_request = Input.get_axis("Left", "Right")
		kart.accel_request = Input.get_axis("Backward", "Forward")
		kart.break_request = Input.is_action_pressed("Backward")
		kart.hop_request = Input.is_action_just_pressed("Drift")
		kart.drift_request = Input.is_action_pressed("Drift")
