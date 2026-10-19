class_name ItemHandler
extends Node

# Signals
signal item_changed(held_item) ## Emitted when [member held_item] changes with it's new value.

# Export Vars
@export var kart: Kart3D ## The kart this item handler is associated with.
@export var debug_item: Item ## DEBUG: REMOVE LATER

# Internal Vars
var held_item: Item: ## The current held item.
	set(value):
		held_item = value
		_update_trail_item()
		item_changed.emit(held_item)
var trailed_item: ItemModel ## The current trailed item.

func _ready() -> void:
	get_item.call_deferred(debug_item) # DEBUG

func _process(_delta: float) -> void:
	# If item request input detected, attempt to use item
	if kart.item_request:
		use_item()

## Called when an item is obtained.
func get_item(item: Item) -> void:
	# If existing item, don't get item
	if held_item:
		return
	
	# Set new held item
	held_item = item

## Called when an item is used.
func use_item(_is_forward: bool = false, _direction: Vector3 = Vector3.ZERO) -> void:
	# Don't use if no held item
	if not held_item:
		return
	
	# Add item entity to world
	var new_item := held_item.entity.instantiate()
	get_tree().current_scene.add_child(new_item)
	
	# Place in front of kart and set facing direction if item is to be thrown
	if held_item is ThrowableItem:
		new_item.rotation.y = kart.rotation.y
		new_item.global_position = kart.global_position + -kart.global_basis.z * 2 + kart.global_basis.y
	
	# Remove held item
	held_item = null

## Called when the [member held_item] changes to update the [member trailed_item].
func _update_trail_item() -> void:
	# Free previous trailed item and return if no current held item
	if trailed_item:
		trailed_item.queue_free()
	if not held_item:
		return
	
	# Create new item model and trail it
	var new_trail: ItemModel = held_item.model.instantiate()
	kart.add_child(new_trail)
	new_trail.scale *= 0.3
	new_trail.global_position += kart.global_basis.z * 1.3 + kart.global_basis.y / 2
	trailed_item = new_trail
