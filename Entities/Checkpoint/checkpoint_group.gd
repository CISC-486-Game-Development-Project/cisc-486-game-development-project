@tool
extends Node3D

@export_tool_button("Refresh Neighbours", "Reload") var refresh_action = refresh_neighbours

func refresh_neighbours():
	var previous_child: Checkpoint = null
	for child in get_children():
		if previous_child != null:
			previous_child.next_checkpoint = child
		previous_child = child
	previous_child.next_checkpoint = get_child(0)
