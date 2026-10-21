## Implementation class for handling inputs from a CPU.
class_name CPUInputHandler
extends InputHandler

## Handles the input coming from the CPU AI based on the kart's environmental conditions.
func handle_input() -> void:
	if kart:
		kart.steer_request = _handle_steering()
		kart.accel_request = _handle_acceleration()
		kart.hop_request = _handle_hopping()
		kart.drift_request = _handle_drifting()
		kart.item_request = _handle_item()

## Returns a float for how the CPU should steer this frame (-1.0 for left to 1.0 for right).
func _handle_steering() -> float:
	return 0.0

## Returns a float for how the CPU should accelerate this frame (-1.0 for backwards, 1.0 for forwards).
func _handle_acceleration() -> float:
	return 1.0

## Returns a bool for if the CPU should hop this frame.
func _handle_hopping() -> bool:
	return false

## Returns a bool for if the CPU should drift this frame.
func _handle_drifting() -> bool:
	return false

## Returns a bool for if the CPU should use an item this frame.
func _handle_item() -> bool:
	return false
