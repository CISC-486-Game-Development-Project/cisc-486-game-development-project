## Singleton for managing sound effects.
extends Node3D

## Plays a sound.
func create_sound(sound: AudioStream) -> void:
	# Create new AudioStreamPlayer based on input AudioStream
	var new_sound: AudioStreamPlayer = AudioStreamPlayer.new()
	new_sound.stream = sound
	
	# Connect signal to destroy once finished
	new_sound.finished.connect(new_sound.queue_free)
	
	# Add to scene and play sound
	add_child(new_sound)
	new_sound.play()

## Plays a positional sound at a specified location.
func create_sound_at_position(sound: AudioStream, location: Vector3) -> void:
	# Create new AudioStreamPlayer3D based on input AudioStream
	var new_sound: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	new_sound.stream = sound
	
	# Connect signal to destroy once finished
	new_sound.finished.connect(new_sound.queue_free)
	
	# Add to scene at position and play sound
	add_child(new_sound)
	new_sound.position = location
	new_sound.play()

## Plays a positional sound attached to a specified parent node.
func create_sound_with_parent(sound: AudioStream, parent: Node3D) -> void:
	# Create new AudioStreamPlayer3D based on input AudioStream
	var new_sound: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	new_sound.stream = sound
	
	# Connect signal to destroy once finished
	new_sound.finished.connect(new_sound.queue_free)
	
	# Add to parent node and play sound
	parent.add_child(new_sound)
	new_sound.play()
