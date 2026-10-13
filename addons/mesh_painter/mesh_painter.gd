## Plugin used for painting meshes onto a MultiMesh.
@tool
class_name MeshPainter
extends MultiMeshInstance3D

# Signals
signal clear_requested ## Emitted when a request to clear all painted meshes is made.

# Export Vars
@export var clear_all: bool = false: ## Boolean export that acts as a clear request button.
	set(value):
		if value and Engine.is_editor_hint(): # When in editor, emit clear request and never set to true.
			call_deferred("emit_signal", "clear_requested")

@export var ground: MeshInstance3D ## The ground mesh to be painted on.
@export var paint_mesh: Mesh ## The mesh used for populating the MultiMesh.
@export var painting: bool = false ## When true, paint functionality is enabled.
@export var radius: float = 2.0 ## The radius of the paintbrush.
@export var meshes_per_stroke: int = 40 ## The number of meshes to paint per stroke. Higher = greater density.
@export var scale_variation: float = 0.2 ## The variation in scale of the meshes, expressed as a percentage.
@export var is_grass: bool ## Determines if the painted meshes will be treated as grass.

@export_storage var points := PackedVector3Array() ## Storage for the points array not exposed to the editor.

# Internal Vars
var _tri: TriangleMesh ## The TriangleMesh cache for the current ground.
var _tri_source: Mesh ## The source ground mesh for the TriangleMesh cache.

## Adds meshes within the brush radius at a surface hit, or removes them when erasing, then rebuilds.
func paint(hit_local: Vector3, normal: Vector3, erase: bool) -> void:
	# If erasing (shift + click & drag)
	if erase:
		# Erase points if within radius by not keeping them
		var kept := PackedVector3Array()
		for p in points:
			if p.distance_to(hit_local) > radius:
				kept.append(p)
		points = kept
	
	# If painting (click & drag)
	else:
		# Handle TriangleMesh cache
		var mesh := ground.mesh # Get ground mesh
		if mesh == null:
			return # Return if no ground mesh
		if mesh != _tri_source: # If current ground mesh is different than the source of the cached TriangleMesh, generate a new TriangleMesh to cache
			_tri_source = mesh # Set new _tri_source
			_tri = mesh.generate_triangle_mesh() # TriangleMesh built from the ground mesh
			mesh.changed.connect(_invalidate_tri, CONNECT_ONE_SHOT) # Invalidate the existing _tri_source if the current ground mesh changes
		
		# Get arbitrary tangent and bitangent perpendicular to normal (together, these three give us an orthonormal basis)
		var t := normal.cross(Vector3.UP if absf(normal.y) < 0.99 else Vector3.RIGHT).normalized()
		var bt := normal.cross(t)
		
		# Handle logic for each mesh in the stroke
		for i in meshes_per_stroke:
			# Combine a random angle and distance from the center within the radius to determine where the mesh will be placed
			var ang := randf() * TAU # Random direction angle
			var d := sqrt(randf()) * radius # Random distance from center in radius (uniform over the disc)
			
			# Convert random angle and distance into a 3D point on the disc in local space + the normal (1 unit) so it sits on the surface of the ground mesh
			var start := hit_local + (t * cos(ang) + bt * sin(ang)) * d + normal
			
			# Re-project ray onto the ground mesh's surface, mapping the disc along the ground mesh's curves
			var res := _tri.intersect_ray(start, -normal)
			if not res.is_empty(): # Skip mesh placement if the ray misses, otherwise append it's position to the points array
				points.append(res["position"])
	
	# Regenerate the MultiMesh from the points array after painting new meshes
	rebuild()

## Rebuilds the MultiMesh from the stored points, with stable per-mesh rotation and scale.
func rebuild() -> void:
	# Don't rebuild if no points
	if points.is_empty():
		multimesh = null
		return
	
	# Create MultiMesh using the provided paint_mesh
	var mm := MultiMesh.new()
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.mesh = paint_mesh
	mm.instance_count = points.size()
	
	# Get transform from ground local space to painter local space
	var to_local := global_transform.affine_inverse() * ground.global_transform
	
	# Each mesh gets a random rotation and scale seeded from the mesh's position
	var rng := RandomNumberGenerator.new()
	for i in points.size():
		# Seed with hash map to keep rotation & scale consistent between rebuilds
		rng.seed = hash(points[i])
		
		# Randomize rotation of mesh, then randomize scale of mesh based on scale_variation
		var b := Basis(Vector3.UP, rng.randf() * TAU)
		b = b.scaled(Vector3.ONE * rng.randf_range(1 - scale_variation, 1 + scale_variation))
		
		# Apply transform to mesh using local space transformation
		mm.set_instance_transform(i, Transform3D(to_local.basis.orthonormalized() * b, to_local * points[i]))
	
	# Set MultiMesh to the created MultiMesh
	multimesh = mm

## Replaces all stored points and rebuilds. Used for undo/redo/clear functionality.
func restore_points(new_points: PackedVector3Array) -> void:
	points = new_points
	rebuild()

## Invalidates the cached TriangleMesh. Called when a change in the current ground mesh has been detected.
func _invalidate_tri() -> void:
	_tri_source = null

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		return # Autoloads don't exist in the editor
	if is_grass: # If grass, add to GrassManager registry
		GrassManager.register_material(paint_mesh.surface_get_material(0) as ShaderMaterial)

func _exit_tree() -> void:
	if Engine.is_editor_hint():
		return # Autoloads don't exist in the editor
	if is_grass: # If grass, remove from GrassManager registry
		GrassManager.unregister_material(paint_mesh.surface_get_material(0) as ShaderMaterial)
