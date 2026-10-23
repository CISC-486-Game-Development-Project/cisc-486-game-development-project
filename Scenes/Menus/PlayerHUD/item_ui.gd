extends PanelContainer

# Export Vars
@export var item_handler: ItemHandler ## The item handler this ui reads from.

# Onready Vars
@onready var item_texture: TextureRect = $MarginContainer/ItemTexture

func _ready() -> void:
	item_handler.inventory_changed.connect(_set_item_visual)

## Called when the item handler's held item changes to display the item's texture.
func _set_item_visual(inventory: Array[Item]) -> void:
	var item = inventory[0] if inventory else null # TODO: Replace this with something else if we use multiple slots
	if item:
		item_texture.texture = item.texture
	else:
		item_texture.texture = null
