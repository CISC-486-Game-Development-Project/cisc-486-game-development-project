@tool
extends EditorScript

func _run() -> void:
	var node := EditorInterface.get_selection().get_selected_nodes()[0] as MeshInstance3D
	var aabb := node.mesh.get_aabb()
	print("position (min corner): ", aabb.position)
	print("size: ", aabb.size)
	print("end (max corner): ", aabb.end)
