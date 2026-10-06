extends Control

@export_file("*.tscn") var next_scene: String = "res://Scenes/"
@export_file("*.tscn") var prev_scene: String = "res://Scenes/"
@export var temp_next_button: Button ## Replace this with some kind of check if player has selected a track.
@export var prev_button: Button

@export_group("Track Buttons")
@export var track_button_1: Button
@export var track_button_2: Button
@export var track_button_3: Button
@export var track_button_4: Button

func _ready() -> void:
	# Connect button signals
	temp_next_button.pressed.connect(_on_next_pressed)
	prev_button.pressed.connect(_on_prev_pressed)
	
	# Focus first button
	track_button_1.grab_focus()
	
	# Load scenes
	SceneManager.load_scene(next_scene)
	SceneManager.load_scene(prev_scene)

## Called when a track is selected.
func _on_next_pressed() -> void:
	SceneManager.change_scene(next_scene)

## Called when going backwards in the menu order.
func _on_prev_pressed() -> void:
	SceneManager.change_scene(prev_scene, SceneManager.SLIDE_BACKWARD)
