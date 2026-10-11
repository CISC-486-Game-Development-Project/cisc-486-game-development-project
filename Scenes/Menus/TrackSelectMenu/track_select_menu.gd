extends Control

# Export Vars
@export_file("*.tscn") var next_scene: String = "res://Scenes/"
@export_file("*.tscn") var prev_scene: String = "res://Scenes/"
@export var prev_button: Button

# Onready Vars
@onready var track_button_container: HBoxContainer = $MarginContainer/VBoxContainer/PanelContainer/MarginContainer/TrackButtonContainer

# Internal Vars
var track_buttons: Array[TrackButton] ## The track buttons available to select.

func _ready() -> void:
	# Get track_buttons
	for child in track_button_container.get_children():
		if child is TrackButton:
			track_buttons.append(child)
	
	# Connect button signals
	prev_button.pressed.connect(_on_prev_pressed)
	
	for i in len(track_buttons):
		track_buttons[i].pressed.connect(select_track.bind(track_buttons[i]))
		track_buttons[i].mouse_entered.connect(track_buttons[i].grab_focus)
	
	# Focus first button
	track_buttons[0].grab_focus()
	
	# Play sync stream
	AudioManager.change_sync_track(2)
	
	# Load scenes
	SceneManager.load_scene(next_scene)
	SceneManager.load_scene(prev_scene)

## Called when a track is selected.
func select_track(button: TrackButton) -> void:
	SceneManager.change_scene(button.track, SceneManager.FADE, false)

## Called when going backwards in the menu order.
func _on_prev_pressed() -> void:
	SceneManager.change_scene(prev_scene, SceneManager.SLIDE_BACKWARD)
