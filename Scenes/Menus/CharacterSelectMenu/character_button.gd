@tool
class_name CharacterButton
extends Button

# Export Vars
@export var character: Character:
	set(value):
		character = value
		set_visuals()

# Onready Vars
@onready var label: Label = $Label
@onready var texture_rect: TextureRect = $TextureRect
@onready var panel: Panel = $Panel

func _ready() -> void:
	set_visuals()

## Sets the visual elements of this button.
func set_visuals() -> void:
	if label:
		label.text = character.char_name + "\nin the\n" + character.kart_name if character.kart_name != "" else character.char_name
	if texture_rect:
		texture_rect.texture = character.char_icon
