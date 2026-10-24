extends PanelContainer

# Onready Vars
@onready var item_texture: TextureRect = $MarginContainer/ItemTexture

## Called when the item handler's held item changes to display the item's texture.
func set_item_visual(item: Item) -> void:
	if item:
		item_texture.texture = item.texture
	else:
		item_texture.texture = null
