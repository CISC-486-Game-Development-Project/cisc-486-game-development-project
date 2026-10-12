extends Control

# Constants
const FOCUS_TWEEN_TIME: float = 0.1
const FOCUS_TWEEN_SCALE: float = 1.1

# Export Vars
@export_file("*.tscn") var singleplayer_scene: String = "res://Scenes/"
@export_file("*.tscn") var multiplayer_scene: String = "res://Scenes/"
@export_file("*.tscn") var prev_scene: String = "res://Scenes/"
@export var singleplayer_button: Button
@export var multiplayer_button: Button
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
	singleplayer_button.pressed.connect(_on_singleplayer_pressed)
	multiplayer_button.pressed.connect(_on_multiplayer_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	for button in button_container.get_children():
		if button is Button:
			button.mouse_entered.connect(button.grab_focus)
	
	get_viewport().gui_focus_changed.connect(_on_focus_changed)
	
	# Handle focus
	options_menu.hiding.connect(_claim_focus)
	_claim_focus()
	
	# Play menu music and/or set sync stream
	AudioManager.change_bgm(menu_music)
	AudioManager.change_sync_track(0, 1)
	
	# Load scenes
	#SceneManager.load_scene(prev_scene)
	SceneManager.load_scene(singleplayer_scene)
	SceneManager.load_scene(multiplayer_scene)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if options_menu.visible:
			options_menu.hide_menu()
		else:
			_prev_scene()

## Called when the singleplayer button is pressed.
func _on_singleplayer_pressed() -> void:
	Globals.player_count = 1
	SceneManager.change_scene(singleplayer_scene, SceneManager.SLIDE_FORWARD)

## Called when the multiplayer button is pressed.
func _on_multiplayer_pressed() -> void:
	SceneManager.change_scene(multiplayer_scene, SceneManager.SLIDE_FORWARD)

## Called when the options button is pressed.
func _on_options_pressed() -> void:
	options_menu.show_menu()

## Called when the quit button is pressed.
func _on_quit_pressed() -> void:
	get_tree().quit()

## Called when going backwards in the menu order.
func _prev_scene() -> void:
	SceneManager.change_scene(prev_scene, SceneManager.SLIDE_BACKWARD)

## Called when focus is unclaimed.
func _claim_focus() -> void:
	singleplayer_button.grab_focus()

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
	if not (new_focus in button_container.get_children()):
		return
	
	# Enlarge new focus
	tween.tween_property(current_focus, "scale", Vector2(FOCUS_TWEEN_SCALE, FOCUS_TWEEN_SCALE), FOCUS_TWEEN_TIME)
