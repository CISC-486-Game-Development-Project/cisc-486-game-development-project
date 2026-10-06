## Singleton for managing scene switches and loading.
extends Node

signal _awaited_scene_loaded
signal load_finished

var loading_screen_packed: PackedScene = preload("uid://b4fkpdlylvkki")
var loading_screen: CanvasLayer

var loaded_scenes: Dictionary[String, PackedScene]
var in_process_loads: Dictionary[String, float]
var errored_loads: Array[String]

var waiting_for_scene: String

enum {INSTANT, SLIDE_FORWARD, SLIDE_BACK, FADE}
const FORWARD_FROM_DIR := Vector2.RIGHT

func _process(_delta: float) -> void:
	for in_process_load in in_process_loads.keys():
		var progress: Array[float] = []
		var load_status = ResourceLoader.load_threaded_get_status(in_process_load, progress)
		in_process_loads[in_process_load] = progress[0]
		
		match load_status:
			ResourceLoader.THREAD_LOAD_INVALID_RESOURCE, ResourceLoader.THREAD_LOAD_FAILED:
				in_process_loads.erase(in_process_load) # This doesn't change the array returned by .keys()
				printerr("Couldn't load " + in_process_load)
				errored_loads.append(in_process_load)
			ResourceLoader.THREAD_LOAD_LOADED:
				var loaded_resource = ResourceLoader.load_threaded_get(in_process_load)
				in_process_loads.erase(in_process_load) # This doesn't change the array returned by .keys()
				loaded_scenes[in_process_load] = loaded_resource
				if in_process_load == waiting_for_scene:
					waiting_for_scene = ""
					_awaited_scene_loaded.emit()

func load_scene(scene_path: String, use_sub_threads: bool = false):
	if scene_path in errored_loads:
		printerr("Trying to load scene which has already failed to load")
	if scene_path in loaded_scenes.keys():
		return
	in_process_loads[scene_path] = 0.0
	var state = ResourceLoader.load_threaded_request(scene_path, "PackedScene", use_sub_threads)
	if state != OK:
		printerr(state)
		errored_loads.append(scene_path)

func change_scene(scene_path: String, animation := FADE):
	if scene_path in errored_loads:
		printerr("Trying to change to scene which has already failed to load")
	if scene_path not in loaded_scenes.keys() and scene_path not in in_process_loads.keys():
		print("Shouldn't be happenning rn")
		load_scene(scene_path)
	# At this point the scene is either loaded or in the process of being loaded
	# This is where anything that doesn't require the scene to be loaded should be done
	get_tree().current_scene.process_mode = Node.PROCESS_MODE_DISABLED
	if animation == FADE:
		loading_screen = loading_screen_packed.instantiate()
		add_child(loading_screen)
		load_finished.connect(loading_screen._on_load_finished)
	
	# Wait until the scene is loaded
	if scene_path not in loaded_scenes.keys():
		print("Weird")
		waiting_for_scene = scene_path
		await _awaited_scene_loaded
	
	# Transition to the scene
	var scene_node = loaded_scenes[scene_path].instantiate()
	var prev_process_mode: ProcessMode = scene_node.process_mode
	scene_node.process_mode = Node.PROCESS_MODE_DISABLED # Pause the scene until the transition is done
	match animation:
		INSTANT:
			get_tree().change_scene_to_node(scene_node)
		FADE:
			await loading_screen.wait_until_ready()
			get_tree().change_scene_to_node(scene_node)
			load_finished.emit()
			await loading_screen.wait_until_ready()
		SLIDE_FORWARD, SLIDE_BACK:
			var vp := get_viewport().get_visible_rect().size
			var FROM_DIR = FORWARD_FROM_DIR if animation == SLIDE_FORWARD else -FORWARD_FROM_DIR
			scene_node.position = FROM_DIR * vp
			get_tree().root.add_child(scene_node)
			var t := create_tween().set_parallel()
			t.tween_property(get_tree().current_scene, "position", -FROM_DIR * vp, 0.3)
			t.tween_property(scene_node, "position", Vector2.ZERO, 0.3)
			await t.finished
			get_tree().unload_current_scene()
			get_tree().current_scene = scene_node
	scene_node.process_mode = prev_process_mode # Return the scene to its previous process
