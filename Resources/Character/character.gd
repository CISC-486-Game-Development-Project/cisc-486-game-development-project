## A data container resource for defining a character.
class_name Character
extends Resource

# Export Vars
@export var char_name: String ## The name of this character.
@export var kart_name: String ## The name of this character's kart.
@export var char_icon: Texture ## The icon associated with this character.
@export var stats: KartStats ## The in-game stats of this character. This includes the character/kart models.
