extends Control

@export var next_scene: StringName = &""
@export var prev_scene: StringName = &""
@export var temp_next_button: Button ## Replace this with some kind of check if player has selected a track.
@export var prev_button: Button

func _ready() -> void:
	# Connect button signals
	temp_next_button.pressed.connect(_on_next_pressed)
	prev_button.pressed.connect(_on_prev_pressed)

## Called when a track is selected.
func _on_next_pressed() -> void:
	SceneManager.load_scene(next_scene)

## Called when going backwards in the menu order.
func _on_prev_pressed() -> void:
	SceneManager.load_scene(prev_scene)
