@tool
class_name CharacterButton
extends Button

# Export Vars
@export var character: Character:
	set(value):
		character = value
		set_visuals()

func _ready() -> void:
	set_visuals()

## Sets the visual elements of this button.
func set_visuals() -> void:
	icon = character.char_icon
