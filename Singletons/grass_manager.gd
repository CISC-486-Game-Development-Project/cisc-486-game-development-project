extends Node

# Constants
const MAX_DISPLACERS := 16  ## The maximum number of displacers. Must match MAX_DISPLACERS in the grass shader.

# Internal Vars
var grass_materials: Array[ShaderMaterial] = [] ## Array of every ShaderMaterial that uses the grass shader. (Usually just the one, but just in case more are made)

## Adds a grass material to the update list (ignores duplicates).
func register_material(material: ShaderMaterial) -> void:
	if material != null and not grass_materials.has(material):
		grass_materials.append(material)

## Removes a grass material from the update list.
func unregister_material(material: ShaderMaterial) -> void:
	grass_materials.erase(material)

func _physics_process(_delta: float) -> void:
	# Initialize data array to send to grass_materials
	var data := PackedVector4Array()
	data.resize(MAX_DISPLACERS) # Set size to MAX_DISPLACERS since shaders require static sized arrays
	
	# Initialize count of displacers
	var count := 0
	
	# Get position and displace_radius data from the grass_displacers group
	for node in get_tree().get_nodes_in_group("grass_displacers"):
		if count >= MAX_DISPLACERS:
			break # Break from loop if too many displacers
		
		# Get position and radius, then add them to data and increment count
		var p: Vector3 = node.global_position
		var r: float = node.get_meta("displace_radius", 1.5)
		data[count] = Vector4(p.x, p.y, p.z, r)
		count += 1
	
	# Set displacers and displacer_count for grass_materials
	for mat in grass_materials:
		mat.set_shader_parameter("displacers", data)
		mat.set_shader_parameter("displacer_count", count)
