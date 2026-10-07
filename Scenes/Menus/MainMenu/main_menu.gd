extends Control

# Constants
const FOCUS_TWEEN_TIME: float = 0.1
const FOCUS_TWEEN_SCALE: float = 1.1

# Export Vars
@export_file("*.tscn") var start_scene: String = "res://Scenes/"
@export var start_button: Button
@export var options_button: Button
@export var quit_button: Button
@export var menu_music: AudioStream

# Onready Vars
@onready var options_menu: CanvasLayer = $OptionsMenu
@onready var button_container: VBoxContainer = $MarginContainer/HBoxContainer/ButtonContainer

# Internal Vars
var current_focus: Control

func _ready() -> void:
	# Connect button signals
	start_button.pressed.connect(_on_start_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	for button in button_container.get_children():
		if button is Button:
			button.mouse_entered.connect(button.grab_focus)
	
	get_viewport().gui_focus_changed.connect(_on_focus_changed)
	
	# Handle focus
	options_menu.hiding.connect(_claim_focus)
	_claim_focus()
	
	# Play menu music
	AudioManager.change_bgm(menu_music)
	
	# Load scenes
	SceneManager.load_scene(start_scene)

## Called when the start button is pressed.
func _on_start_pressed() -> void:
	SceneManager.change_scene(start_scene, SceneManager.SLIDE_FORWARD)

## Called when the options button is pressed.
func _on_options_pressed() -> void:
	options_menu.show_menu()

## Called when the quit button is pressed.
func _on_quit_pressed() -> void:
	get_tree().quit()

## Called when focus is unclaimed.
func _claim_focus() -> void:
	start_button.grab_focus()

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
	if not new_focus in button_container.get_children():
		return
	
	# Enlarge new focus
	tween.tween_property(current_focus, "scale", Vector2(FOCUS_TWEEN_SCALE, FOCUS_TWEEN_SCALE), FOCUS_TWEEN_TIME)
