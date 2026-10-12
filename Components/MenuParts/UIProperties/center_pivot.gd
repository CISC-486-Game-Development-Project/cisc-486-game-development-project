class_name CenterPivot
extends Node

@onready var to_center: Control = get_parent() ## The node to have it's pivot set to it's center.

func _ready() -> void:
	_center_pivot()

func _process(_delta: float) -> void:
	_center_pivot() # HACK: This is stupid. I don't know why size.y is always really small when trying to set this on ready.

## Centers the pivot based on the node's size.
func _center_pivot() -> void:
	to_center.pivot_offset = to_center.size/2
