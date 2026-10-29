extends PanelContainer

# Onready Vars
@onready var item_texture: TextureRect = $MarginContainer/ItemTexture
@onready var rolling_textures: Control = $RollingContainer/MarginContainer/RollingTextures

var rolling: bool = false

## Called when the item handler's held item changes to display the item's texture.
func set_item_visual(item: Item) -> void:
	stop_roll()
	if item:
		item_texture.texture = item.texture
	else:
		item_texture.texture = null

func start_roll():
	if not rolling:
		rolling = true
		rolling_textures.visible = true
		item_texture.visible = false
		var item_order: Array[Item] = ItemManager.items.duplicate()
		item_order.shuffle()
		item_order.append(item_order[0])
		item_order.append(item_order[1])
		item_order.append(item_order[2])
		for item in item_order:
			var new_item_texture = item_texture.duplicate()
			new_item_texture.texture = item.texture
			new_item_texture.size_flags_vertical = Control.SIZE_EXPAND_FILL
			new_item_texture.visible = true
			new_item_texture.custom_maximum_size.y = 104
			rolling_textures.add_child(new_item_texture)
		rolling_textures.visible = true
		rolling_textures.offset_transform_enabled = true
		rolling_textures.offset_transform_position.y = -rolling_textures.get_child(1).position.y

func stop_roll():
	if rolling:
		print(1)
		rolling = false
		rolling_textures.visible = false
		item_texture.visible = true

func _process(_f):
	if rolling:
		rolling_textures.offset_transform_position.y -= 13
		if rolling_textures.offset_transform_position.y <= ((ItemManager.items.size()) * -108):
			rolling_textures.offset_transform_position.y = 0
	
	
