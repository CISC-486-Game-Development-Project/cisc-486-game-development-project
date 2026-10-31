extends Control

# Constants
const TWEEN_TIME: float = 0.1

# Export Vars
@export_file("*.tscn") var next_scene: String = "res://Scenes/" ## The next scene to progress to.
@export_file("*.tscn") var prev_scene: String = "res://Scenes/" ## The prev scene to return to.
@export var controller_texture: Texture ## The texture to show when a controller is connected.

# Onready Vars
@onready var image_panels: HBoxContainer = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/ControllerPanels
@onready var name_panels: HBoxContainer = $MarginContainer/PanelContainer/MarginContainer/VBoxContainer/NamePanels

# Internal Vars
var controller_images: Array[TextureRect] ## An array storing the texture rects for controller images.
var controller_names: Array[Label] ## An array storing the labels for controller names.

func _ready() -> void:
	# Get controller images & names
	for panel in image_panels.get_children():
		controller_images.append(panel.get_node("MarginContainer/TextureRect"))
	for panel in name_panels.get_children():
		controller_names.append(panel.get_node("Label"))
	
	# Initialize joypad handling
	_handle_joypads()

func _process(_delta: float) -> void:
	_handle_joypads()

func _input(event: InputEvent) -> void:
	# Tween on button press to visually demonstrate which controller is which
	if event.device in range(4) and event is InputEventJoypadButton:
		if event.is_pressed():
			_tween_controller_image(controller_images[event.device])
	
	# Progress to next scene if accept pressed and more than one joypad connected
	if event.is_action_pressed("ui_accept") and len(Input.get_connected_joypads()) > 1:
		_next_scene()
	# Return to previous scene if cancel pressed
	elif event.is_action_pressed("ui_cancel"):
		_prev_scene()

## Handles logic and visuals concerning the number of joypads connected.
func _handle_joypads() -> void:
	var joypads := Input.get_connected_joypads()
	
	# Set visuals for joypads
	for i in range(4):
		if len(joypads) >= i+1:
			controller_images[i].texture = controller_texture
			controller_names[i].text = Input.get_joy_name(joypads[i])
			RaceManager.player_devices[i] = joypads[i]
		else:
			controller_images[i].texture = null
			controller_names[i].text = ""
			RaceManager.player_devices[i] = -1

## Play a quick tween animation on a controller image.
## Called when a joypad button is pressed.
func _tween_controller_image(image: TextureRect) -> void:
	var tween = create_tween()
	tween.tween_property(image, "scale", Vector2(1.1, 1.1), TWEEN_TIME/2)
	tween.parallel().tween_property(image, "position", Vector2(16.0, 16.0), TWEEN_TIME/2)
	tween.tween_property(image, "scale", Vector2(1.0, 1.0), TWEEN_TIME/2)
	tween.parallel().tween_property(image, "position", Vector2(32.0, 32.0), TWEEN_TIME/2)

## Called when the next button is pressed.
func _next_scene() -> void:
	RaceManager.player_count = clampi(len(Input.get_connected_joypads()), 1, 4)
	SceneManager.change_scene(next_scene, SceneManager.SLIDE_FORWARD)

## Called when the back button is pressed.
func _prev_scene() -> void:
	SceneManager.change_scene(prev_scene, SceneManager.SLIDE_BACKWARD)
