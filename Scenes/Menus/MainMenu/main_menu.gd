extends Control

# Export Vars
@export var start_scene: PackedScene
@export var start_button: Button
@export var options_button: Button
@export var quit_button: Button
@export var menu_music: AudioStream

# Onready Vars
@onready var options_menu: CanvasLayer = $OptionsMenu

func _ready() -> void:
	# Connect button signals
	start_button.pressed.connect(_on_start_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	
	# Focus first button
	start_button.grab_focus()
	
	# Play menu music
	AudioManager.change_bgm(menu_music)

## Called when the start button is pressed.
func _on_start_pressed() -> void:
	SceneManager.load_scene(start_scene)

## Called when the options button is pressed.
func _on_options_pressed() -> void:
	options_menu.visible = true

## Called when the quit button is pressed.
func _on_quit_pressed() -> void:
	get_tree().quit()
