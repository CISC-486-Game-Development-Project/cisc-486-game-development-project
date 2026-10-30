## Implementation class for handling inputs from a CPU.
class_name CPUInputHandler
extends InputHandler

# Export Vars
@export var target_update_time: float = 5.0 ## The amount of time between target updates.

# Internal Vars
var current_location: Vector3
var current_target: Vector3
var target_update_timer: float
var current_velocity: Vector3
var distance_to_target: float
var direction_to_target: Vector3
var angle_to_target: float

func _process(delta: float) -> void:
	target_update_timer += delta

## Handles the input coming from the CPU AI based on the kart's environmental conditions.
func handle_input() -> void:
	if kart:
		_update_information()
		kart.steer_request = _handle_steering()
		kart.accel_request = _handle_acceleration()
		kart.hop_request = _handle_hopping()
		kart.drift_request = _handle_drifting()
		kart.item_request = _handle_item()
		#print(kart.steer_request, " | ", kart.accel_request, " | ", kart.hop_request)

## Updates the required information from the kart to be used in determining this frame's actions.
func _update_information() -> void:
	current_location = kart.global_position
	if kart.race_handler.most_recent_checkpoint and (kart.navigation_agent_3d.target_position != kart.race_handler.most_recent_checkpoint.next_checkpoint.global_position or target_update_timer > target_update_time):
		kart.navigation_agent_3d.target_position = kart.race_handler.most_recent_checkpoint.next_checkpoint.global_position
		target_update_timer = 0.0
	if kart.offroad_factor > 0.0:
		kart.navigation_agent_3d.target_position = NavigationServer3D.map_get_closest_point(kart.get_world_3d().get_navigation_map(), kart.global_position)
	current_target = kart.navigation_agent_3d.get_next_path_position()
	current_velocity = kart.velocity
	distance_to_target = current_location.distance_to(current_target)
	direction_to_target = current_location.direction_to(current_target)
	angle_to_target = direction_to_target.signed_angle_to(-kart.global_basis.z, Vector3.UP)

## Returns a float for how the CPU should steer this frame (-1.0 for left to 1.0 for right).
func _handle_steering() -> float:
	# Steer if angle to target position is sufficiently large
	if angle_to_target < -0.2:
		return -1.0
	elif angle_to_target > 0.2:
		return 1.0
	return 0.0

## Returns a float for how the CPU should accelerate this frame (-1.0 for backwards, 1.0 for forwards).
func _handle_acceleration() -> float:
	return 1.0 # Always accelerate

## Returns a bool for if the CPU should hop this frame.
func _handle_hopping() -> bool:
	# Hop if one of the raycasts aren't colliding, might be able to trick
	if not kart.trick_ray_cast_3d.is_colliding():
		return true
	if not kart.ground_ray_cast_3d.is_colliding():
		return true
	
	# Hop if angle to target position is sufficiently large, should drift
	if abs(angle_to_target) > 0.5 and not kart.drift_request:
		return true
	return false

## Returns a bool for if the CPU should drift this frame.
func _handle_drifting() -> bool:
	# Drift if angle to target position is sufficiently large
	if angle_to_target < -0.5:
		return true
	elif angle_to_target > 0.5:
		return true
	return false

## Returns a bool for if the CPU should use an item this frame.
func _handle_item() -> bool:
	# Use item if holding item
	if kart.item_handler.is_holding_item():
		return true
	return false
