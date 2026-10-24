extends CanvasLayer

@export var race_handler: RaceHandler
@export var item_handler: ItemHandler

@onready var starting_item_panel = $MarginContainer/VBoxContainer/TopContainer/ItemPanel
@onready var lap_count = $MarginContainer/VBoxContainer/BottomContainer/LapContainer/LapCount

var item_panels: Array[PanelContainer]

func _ready():
	race_handler.lap_changed.connect(_update_laps)
	
	item_handler.inventory_changed.connect(_set_item_visual)
	
	item_panels = [starting_item_panel]
	for item_slot_index in range(1, item_handler.inventory_slots):
		var new_item_panel = starting_item_panel.duplicate()
		item_panels[-1].add_sibling(new_item_panel)
		item_panels.append(new_item_panel)
	_update_laps.call_deferred(race_handler.lap)

func _update_laps(new_count: int) -> void:
	lap_count.text = "%s/%s" % [new_count, race_handler.race_laps]

func _set_item_visual(inventory: Array[Item]):
	for item_slot_index in range(item_handler.inventory_slots):
		if item_handler.inventory.size() > item_slot_index:
			item_panels[item_slot_index].set_item_visual(inventory[item_slot_index])
		else:
			item_panels[item_slot_index].set_item_visual(null)
