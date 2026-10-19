## A generic data class for storing item information.
class_name Item
extends Resource

# Export Vars
@export var name: String ## The name of the item.
@export var texture: Texture ## The texture for the item. To be displayed in UI elements.
@export var model: PackedScene ## The model for the item. Should contain a mesh and hitbox if required.
@export var entity: PackedScene ## The entity for the item. Should define the behaviour for when this item exists in the world if required.
@export var weights: Array[float] ## The weights for obtaining the item, with current race placement as the index.
