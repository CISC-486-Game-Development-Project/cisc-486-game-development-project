class_name ItemHandler
extends Node

# Signals
signal inventory_changed(new_inventory: Array[Item]) ## Emitted when [member held_item] changes with it's new value.
signal item_rolled(item: Item, slot: int) ## Emitted when a player has hit an item block, they will have item once ROLL_TIME has elapsed.

# Export Vars
@export var kart: Kart3D ## The kart this item handler is associated with.
@export var inventory_slots := 1

const ROLL_TIME = 1.5 ## Time between hitting item block and having item

# Internal Vars
var inventory: Array[Item] ## The current held item.
var trailed_item: ItemModel ## The current trailed item.

func _ready() -> void:
	inventory_changed.connect(_update_trail_item)

func _process(_delta: float) -> void:
	# If item request input detected, attempt to use item
	if kart.item_request:
		use_item()
		kart.item_request = false # Request has been handled

## Called when an item is obtained.
func roll_item() -> void:
	# If existing item, don't get item
	if inventory.size() >= inventory_slots:
		return
	
	var new_item = ItemManager.get_random_item(kart.race_handler.position)
	
	item_rolled.emit(new_item, inventory.size())
	
	await get_tree().create_timer(ROLL_TIME).timeout
	# Set new held item
	inventory.append(new_item)
	inventory_changed.emit(inventory)

## Called when an item is used.
func use_item() -> void:
	# Don't use if no held item
	if not is_holding_item():
		return
	
	# Use held item then remove
	var used_item = inventory.pop_front()
	used_item.use(kart)
	inventory_changed.emit(inventory)

## Called when the [member inventory] changes to update the [member trailed_item].
func _update_trail_item(_inventory) -> void:
	# Free previous trailed item and return if no current held item
	if trailed_item:
		trailed_item.queue_free()
	if not is_holding_item():
		return
	
	# Create new item model and trail it
	var new_trail: ItemModel = inventory[0].model.instantiate()
	kart.add_child(new_trail)
	new_trail.scale *= 0.3
	new_trail.global_position += kart.global_basis.z * 1.3 + kart.global_basis.y / 2
	trailed_item = new_trail

## Returns if at least one item is held.
func is_holding_item() -> bool:
	return inventory.size() > 0
