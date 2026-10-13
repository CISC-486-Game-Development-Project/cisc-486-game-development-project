@tool
extends EditorPlugin

# Internal Vars
var target: MeshPainter ## The MeshPainter node this plugin is targeting.
var _stroking := false ## Determines whether or not a stroke is happening.
var _before := PackedVector3Array() ## Snapshot of points array taken before an action.
var _tri: TriangleMesh ## The TriangleMesh cache for the current ground.
var _tri_source: Mesh ## The source ground mesh for the TriangleMesh cache.

## Returns true only for MeshPainter nodes, so the plugin ignores everything else.
func _handles(object: Object) -> bool:
	return object is MeshPainter

## Sets the active painter, commits any open stroke, and connects its clear_requested signal.
func _edit(object: Object) -> void:
	# Commit before the target changes
	if _stroking:
		_end_stroke()
	
	# Disconnect clear request from old target to avoid reacting to a painter that isn't selected
	if target != null and target.clear_requested.is_connected(_on_clear_requested):
		target.clear_requested.disconnect(_on_clear_requested)
	
	# Set new target and connect the clear request signal if not already connected
	target = object as MeshPainter
	if target != null and not target.clear_requested.is_connected(_on_clear_requested):
		target.clear_requested.connect(_on_clear_requested)

## Converts left-drag input in the 3D viewport into paint or shift-erase strokes on the ground mesh.
func _forward_3d_gui_input(camera: Camera3D, event: InputEvent) -> int:
	# Don't do anything with input if no target, not painting, or no ground set.
	if target == null or not target.painting or target.ground == null:
		return AFTER_GUI_INPUT_PASS
	
	# Determine whether or not left mouse button is held while dragging
	var pressed := false
	if event is InputEventMouseMotion:
		pressed = event.button_mask & MOUSE_BUTTON_MASK_LEFT != 0 # Detect mouse drag
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed:
			# Mouse released, finish the stroke if there is one
			if _stroking:
				_end_stroke()
				return AFTER_GUI_INPUT_STOP # Stop if ending a stroke
			return AFTER_GUI_INPUT_PASS # Pass if not stroking
		pressed = true # If not pressed already, now it is
	else: # Ignore other input and pass
		return AFTER_GUI_INPUT_PASS
	
	# Pass if not pressed
	if not pressed:
		return AFTER_GUI_INPUT_PASS
	
	# Get mouse ray vars for calculating the intersection of the mouse ray to the ground
	var origin := camera.project_ray_origin(event.position) # Mouse ray origin in world space
	var dir := camera.project_ray_normal(event.position) # Mouse ray normal in world space
	var inv := target.ground.global_transform.affine_inverse() # World to ground local transform
	
	# Handle TriangleMesh cache
	var mesh := target.ground.mesh # Get ground mesh
	if mesh == null: # Pass if no ground mesh
		return AFTER_GUI_INPUT_PASS
	if mesh != _tri_source: # If current ground mesh is different than the source of the cached TriangleMesh, generate a new TriangleMesh to cache
		_tri_source = mesh # Set new _tri_source
		_tri = mesh.generate_triangle_mesh() # TriangleMesh built from the ground mesh
		mesh.changed.connect(_invalidate_tri, CONNECT_ONE_SHOT) # Invalidate the existing _tri_source if the current ground mesh changes
	
	# Get the point where the mouse ray intersects with the ground mesh (or not) to determine where to paint (or not at all)
	var res := _tri.intersect_ray(inv * origin, inv.basis * dir) # Position and normal in ground local space of where the mouse ray hits the ground
	if res.is_empty(): # res will be empty if mouse ray doesn't intersect with the ground, thus missing the paintable area
		return AFTER_GUI_INPUT_PASS # If so, pass
	
	# Stroke if not stroking already, and keep a duplicate of the points array in _before
	if not _stroking:
		_stroking = true
		_before = target.points.duplicate()
	
	# Paint on the target, or erase if shift is held
	target.paint(res["position"], res["normal"], Input.is_key_pressed(KEY_SHIFT))
	
	# Return stop when painting, as gui input has been handled
	return AFTER_GUI_INPUT_STOP

## Commits the finished stroke as a single undo action, skipping it if nothing changed.
func _end_stroke() -> void:
	# No more stroking
	_stroking = false
	
	# Return if target doesn't exist
	if target == null:
		return
	
	# Get a duplicate of the points array
	var after := target.points.duplicate()
	if after == _before:
		return # Return if nothing changed (ex. erased empty area)
	
	# Add stroke to the undo/redo systm so the godot engine can handle it
	var ur := get_undo_redo() # Get a reference to the undo/redo system
	ur.create_action("Paint Meshes", UndoRedo.MERGE_DISABLE, target) # Create a new u/r action for a stroke of painting meshes
	ur.add_do_method(target, "restore_points", after) # Call restore_points with after on "do" (resets points array to how it is after the stroke)
	ur.add_undo_method(target, "restore_points", _before) # Call restore_points with _before on "undo" (resets points array to how it is before the stroke)
	ur.commit_action(false) # Commit action and set execute to false because the stroke is already applied (don't re-run "do")

## Clears all painted meshes as one undoable action.
func _on_clear_requested() -> void:
	# Do nothing if no target or no points to clear
	if target == null or target.points.is_empty():
		return
	
	# If you're somehow stroking while clicking the clear button, that stroke is over now
	if _stroking:
		_end_stroke()
	
	# Get a reference to the current points array
	var before := target.points.duplicate()
	
	# Add clear to the undo/redo systm so the godot engine can handle it
	var ur := get_undo_redo() # Get a reference to the undo/redo system
	ur.create_action("Clear All Painted Meshes", UndoRedo.MERGE_DISABLE, target) # Create a new u/r action for clearing all meshes on a MeshPainter
	ur.add_do_method(target, "restore_points", PackedVector3Array()) # Call restore_points with an empty array on "do" (resets points array to empty)
	ur.add_undo_method(target, "restore_points", before) # Call restore_points with before on "undo" (resets points array to how it is before the clear)
	ur.commit_action() # Commit action and execute (runs "do" now, setting the points array to be empty)

## Invalidates the cached TriangleMesh. Called when a change in the current ground mesh has been detected.
func _invalidate_tri() -> void:
	_tri_source = null
