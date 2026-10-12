extends Control

# Constants
const FOCUS_TWEEN_TIME: float = 0.1
const FOCUS_TWEEN_SCALE: float = 1.1

# Export Vars
@export_file("*.tscn") var next_scene: String = "res://Scenes/"
@export_file("*.tscn") var prev_scene: String = "res://Scenes/"
@export var back_button: Button

# Onready Vars
@onready var track_button_container: HBoxContainer = $MarginContainer/VBoxContainer/PanelContainer/MarginContainer/TrackButtonContainer

# Internal Vars
var track_buttons: Array[TrackButton] ## The track buttons available to select.
var current_focus: Control

func _ready() -> void:
	# Get track_buttons
	for child in track_button_container.get_children():
		if child is TrackButton:
			track_buttons.append(child)
	
	# Connect button signals
	back_button.pressed.connect(_prev_scene)
	
	for i in len(track_buttons):
		track_buttons[i].pressed.connect(select_track.bind(track_buttons[i]))
		track_buttons[i].mouse_entered.connect(track_buttons[i].grab_focus)
	
	get_viewport().gui_focus_changed.connect(_on_focus_changed)
	
	# Focus first button
	track_buttons[0].grab_focus()
	
	# Play sync stream
	AudioManager.change_sync_track(2, 1)
	
	# Load scenes
	SceneManager.load_scene(next_scene)
	SceneManager.load_scene(prev_scene)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_prev_scene()

## Called when focused control changes. Uses tweens to accentuate focused control.
func _on_focus_changed(new_focus: Control) -> void:
	# Create new tween
	var tween: Tween = get_tree().create_tween().set_parallel()
	
	# Return old focus to normal
	if current_focus:
		tween.tween_property(current_focus, "scale", Vector2(1,1), FOCUS_TWEEN_TIME)
	
	# Set new focus
	current_focus = new_focus
	
	# Return if new_focus isn't one of the menu buttons
	if not (new_focus in track_buttons):
		return
	
	# Enlarge new focus
	tween.tween_property(current_focus, "scale", Vector2(FOCUS_TWEEN_SCALE, FOCUS_TWEEN_SCALE), FOCUS_TWEEN_TIME)

## Called when a track is selected.
func select_track(button: TrackButton) -> void:
	SceneManager.change_scene(button.track, SceneManager.FADE, false)

## Called when going backwards in the menu order.
func _prev_scene() -> void:
	SceneManager.change_scene(prev_scene, SceneManager.SLIDE_BACKWARD)
