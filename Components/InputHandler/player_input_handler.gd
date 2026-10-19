## Implementation class for handling inputs from a player.
class_name PlayerInputHandler
extends InputHandler

# Constants
const BASE_ACTIONS: Array[StringName] = [ ## Array of named actions from the base InputMap to make player-specific variants of.
	&"Left", &"Right", &"Up", &"Down",
	&"Forward", &"Backward", &"Drift", &"Item",
	&"CameraLeft", &"CameraRight", &"CameraDown", &"CameraUp",
]

# Internal Vars
var player_num: int ## The player this input handler gets input from.

func _ready() -> void:
	_setup_player_actions()

####################
## Input Handling ##
####################

## Handles the input coming from the device associated with the player_num.
func handle_input() -> void:
	if kart:
		kart.steer_request = Input.get_axis(_action_name(&"Left"), _action_name(&"Right"))
		kart.pitch_request = Input.get_axis(_action_name(&"Up"), _action_name(&"Down"))
		kart.accel_request = Input.get_axis(_action_name(&"Backward"), _action_name(&"Forward"))
		kart.brake_request = Input.is_action_pressed(_action_name(&"Backward"))
		kart.hop_request = Input.is_action_just_pressed(_action_name(&"Drift"))
		kart.drift_request = Input.is_action_pressed(_action_name(&"Drift"))
		kart.item_request = Input.is_action_just_pressed(_action_name(&"Item"))
		kart.camera_request = Input.get_vector(_action_name(&"CameraLeft"), _action_name(&"CameraRight"), _action_name(&"CameraDown"), _action_name(&"CameraUp"))

############################
## Action Setup Functions ##
############################

## Gets the name of the action mapped for the specific player_num.
func _action_name(base: StringName) -> StringName:
	return StringName("P%d_%s" % [player_num, base])

## Sets up the InputMap to hold this player's specific actions.
func _setup_player_actions() -> void:
	# Get device from Globals (device = the device id of the controller being used by this player)
	var device: int = Globals.player_devices[player_num - 1] 
	
	# Add player specific actions to the InputMap based on BASE_ACTIONS
	for base_action in BASE_ACTIONS:
		var action := _action_name(base_action)
		
		# If player specific action already exists, erase it
		if InputMap.has_action(action):
			InputMap.erase_action(action)
		
		# Add player specific action
		InputMap.add_action(action, InputMap.action_get_deadzone(base_action))
		
		# Copy controls from the base_action to the player specific action, make them only respond to this player's device
		for event in InputMap.action_get_events(base_action):
			var copy := event.duplicate() as InputEvent
			copy.device = device
			InputMap.action_add_event(action, copy)
