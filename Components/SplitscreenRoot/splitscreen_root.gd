extends Control

@onready var splitscreen_container: GridContainer = $SplitscreenContainer

var sub_viewport_containers: Array[SubViewportContainer]
var sub_viewports: Array[SubViewport]

func _ready() -> void:
	# Get sub_viewport_containers and sub_viewports
	for child in splitscreen_container.get_children():
		if child is SubViewportContainer:
			sub_viewport_containers.append(child)
			var sub_viewport = child.get_node_or_null("SubViewport")
			if sub_viewport is SubViewport:
				sub_viewports.append(sub_viewport)
	
	# Set visibility of sub_viewport_containers based on player_count
	for i in range(4):
		if i >= Globals.player_count:
			sub_viewport_containers[i].hide()
