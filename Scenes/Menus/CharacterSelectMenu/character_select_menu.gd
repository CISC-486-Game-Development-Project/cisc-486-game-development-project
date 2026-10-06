extends Control

# Export Vars
@export var next_scene: PackedScene
@export var prev_scene: PackedScene
@export var temp_next_button: Button ## Replace this with some kind of check if player has selected a kart.
@export var prev_button: Button
@export var character_buttons: Array[Button]

# Onready Vars
@onready var character_button_container: GridContainer = $MarginContainer/HBoxContainer/PanelContainer/MarginContainer/CharacterButtonContainer
@onready var sub_viewport: SubViewport = $MarginContainer/HBoxContainer/VBoxContainer/SubViewportContainer/SubViewport
@onready var name_label: Label = $MarginContainer/HBoxContainer/VBoxContainer/NameLabel

# Internal Vars
var player_num: int = 1 ## The player number this menu is associated with.
var hover_kart: KartModel

func _ready() -> void:
	# Get character_buttons
	for child in character_button_container.get_children():
		if child is CharacterButton:
			character_buttons.append(child)
	
	# Connect button signals
	prev_button.pressed.connect(_prev_scene)
	
	for i in len(character_buttons):
		character_buttons[i].pressed.connect(select_character.bind(character_buttons[i]))
		character_buttons[i].focus_entered.connect(hover_character.bind(character_buttons[i]))
		character_buttons[i].mouse_entered.connect(character_buttons[i].grab_focus)
	
	# Focus first button
	character_buttons[0].grab_focus()

func _process(delta: float) -> void:
	if hover_kart:
		hover_kart.rotate_y(delta)

## Called when a character is selected.
func select_character(button: CharacterButton):
	# Set player's selected character
	Globals.selected_characters[player_num-1] = button.character
	
	# Return if not all players have selected characters
	for i in range(Globals.player_count):
		if not Globals.selected_characters[i]:
			return
	
	# Progress to next scene when all players have selected characters
	_next_scene()

## Called when a character is hovered.
func hover_character(button: CharacterButton):
	# Clean up previous hovered kart
	for child in sub_viewport.get_children():
		if child is KartModel:
			child.queue_free()
	
	# Add new hovered kart and change text
	var new_char = button.character
	hover_kart = new_char.stats.kart_model.instantiate()
	sub_viewport.add_child(hover_kart)
	name_label.text = new_char.char_name + "\nin the\n" + new_char.kart_name if new_char.kart_name != "" else new_char.char_name

## Called when all characters are selected.
func _next_scene() -> void:
	SceneManager.load_scene(next_scene)

## Called when going backwards in the menu order.
func _prev_scene() -> void:
	SceneManager.load_scene(prev_scene)
