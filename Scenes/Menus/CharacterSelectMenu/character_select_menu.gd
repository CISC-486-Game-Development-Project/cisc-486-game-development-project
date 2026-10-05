extends Control

@export var next_scene: PackedScene
@export var prev_scene: PackedScene
@export var temp_next_button: Button ## Replace this with some kind of check if player has selected a kart.
@export var prev_button: Button

@export_group("Kart Buttons")
@export var kart_button_1: Button
@export var kart_button_2: Button
@export var kart_button_3: Button
@export var kart_button_4: Button


func _ready() -> void:
	# Connect button signals
	temp_next_button.pressed.connect(_on_next_pressed)
	prev_button.pressed.connect(_on_prev_pressed)
	
	# Focus first button
	kart_button_1.grab_focus()

## Called when a character/kart is selected.
func _on_next_pressed() -> void:
	SceneManager.load_scene(next_scene)

## Called when going backwards in the menu order.
func _on_prev_pressed() -> void:
	SceneManager.load_scene(prev_scene)
