extends PanelContainer

# Export Vars
@export var item_handler: ItemHandler ## The item handler this ui reads from.

# Onready Vars
@onready var item_texture: TextureRect = $MarginContainer/ItemTexture

func _ready() -> void:
	item_handler.item_changed.connect(_set_item_visual)

## Called when the item handler's held item changes to display the item's texture.
func _set_item_visual(item: Item = null) -> void:
	if item:
		item_texture.texture = item.texture
	else:
		item_texture.texture = null
