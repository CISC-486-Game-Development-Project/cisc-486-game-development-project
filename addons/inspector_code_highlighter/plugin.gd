@tool
extends EditorPlugin

var _inspector_plugin: EditorInspectorPlugin = preload("./inspector_plugin.gd").new()


func _enter_tree() -> void:
	add_inspector_plugin(_inspector_plugin)

func _exit_tree() -> void:
	remove_inspector_plugin(_inspector_plugin)
