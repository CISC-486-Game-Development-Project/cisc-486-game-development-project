## Singleton for managing music, sfx and voice lines.
extends Node3D

# Enums
enum SoundType {
	SFX, ## Used when creating a new sound effect.
	VOICE ## Used when creating a new voice line.
}

# Internal Vars
var current_music: AudioStreamPlayer
var current_sfx: Array = []
var current_voices: Array = []

var master_volume: float = 0.5
var music_volume: float = 0.5
var sfx_volume: float = 0.5
var voice_volume: float = 0.5

## Plays a sound.
func create_sound(sound: AudioStream, type: SoundType = SoundType.SFX) -> void:
	# Create new AudioStreamPlayer based on input AudioStream
	var new_sound: AudioStreamPlayer = AudioStreamPlayer.new()
	new_sound.stream = sound
	
	# Set volume and add the sound to an array based on it's sound type
	if type == SoundType.SFX:
		new_sound.volume_linear = master_volume * sfx_volume
		current_sfx.append(new_sound)
	elif type == SoundType.VOICE:
		new_sound.volume_linear = master_volume * voice_volume
		current_voices.append(new_sound)
	
	# Connect signal to destroy once finished
	new_sound.finished.connect(new_sound.queue_free)
	
	# Add to scene and play sound
	add_child(new_sound)
	new_sound.play()

## Plays a positional sound at a specified location.
func create_sound_at_position(sound: AudioStream, location: Vector3, type: SoundType = SoundType.SFX) -> void:
	# Create new AudioStreamPlayer3D based on input AudioStream
	var new_sound: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	new_sound.stream = sound
	
	# Set volume and add the sound to an array based on it's sound type
	if type == SoundType.SFX:
		new_sound.volume_linear = master_volume * sfx_volume
		current_sfx.append(new_sound)
	elif type == SoundType.VOICE:
		new_sound.volume_linear = master_volume * voice_volume
		current_voices.append(new_sound)
	
	# Connect signal to destroy once finished
	new_sound.finished.connect(new_sound.queue_free)
	
	# Add to scene at position and play sound
	add_child(new_sound)
	new_sound.position = location
	new_sound.play()

## Plays a positional sound attached to a specified parent node.
func create_sound_with_parent(sound: AudioStream, parent: Node3D, type: SoundType = SoundType.SFX) -> void:
	# Create new AudioStreamPlayer3D based on input AudioStream
	var new_sound: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	new_sound.stream = sound
	
	# Set volume and add the sound to an array based on it's sound type
	if type == SoundType.SFX:
		new_sound.volume_linear = master_volume * sfx_volume
		current_sfx.append(new_sound)
	elif type == SoundType.VOICE:
		new_sound.volume_linear = master_volume * voice_volume
		current_voices.append(new_sound)
	
	# Connect signal to destroy once finished
	new_sound.finished.connect(new_sound.queue_free)
	
	# Add to parent node and play sound
	parent.add_child(new_sound)
	new_sound.play()

## Changes the background music to a specified track.
func change_bgm(music: AudioStream, force_restart: bool = false) -> void:
	# Don't change bgm if music is the same as current_music unless force_restart is true
	if current_music and not force_restart:
		if current_music.stream == music:
			return
	
	# Create new AudioStreamPlayer based on input AudioStream
	var new_music: AudioStreamPlayer = AudioStreamPlayer.new()
	new_music.stream = music
	
	# Make sure music still plays when paused
	new_music.process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Set the volume of the music based on volume values
	new_music.volume_linear = master_volume * music_volume
	
	# Replace previous bgm with new one
	if current_music:
		current_music.queue_free()
	current_music = new_music
	
	# Add to scene and play music
	add_child(new_music)
	new_music.play()

## Stops currently playing backrgound music.
func stop_bgm() -> void:
	if current_music:
		current_music.queue_free()

####################
## Volume Setters ##
####################

## Sets the master volume to the specified value in percent.
## Values must be between 0 and 1, or else they will be clamped.
func set_master_volume(value: float) -> void:
	master_volume = clampf(value, 0.0, 1.0)
	_update_volumes()

## Sets the music volume to the specified value in percent.
## Values must be between 0 and 1, or else they will be clamped.
func set_music_volume(value: float) -> void:
	music_volume = clampf(value, 0.0, 1.0)
	_update_volumes()

## Sets the sfx volume to the specified value in percent.
## Values must be between 0 and 1, or else they will be clamped.
func set_sfx_volume(value: float) -> void:
	sfx_volume = clampf(value, 0.0, 1.0)
	_update_volumes()

## Sets the voice volume to the specified value in percent.
## Values must be between 0 and 1, or else they will be clamped.
func set_voice_volume(value: float) -> void:
	voice_volume = clampf(value, 0.0, 1.0)
	_update_volumes()

## Updates the volumes of all existing sounds to match the new volume settings.
## Should be called any time a volume value is set.
func _update_volumes() -> void:
	# Update music volume
	current_music.volume_linear = master_volume * music_volume
	
	# Update sfx volumes
	for sfx in current_sfx:
		sfx.volume_linear = master_volume * sfx_volume
	
	# Update voice volumes
	for voice in current_voices:
		voice.volume_linear = master_volume * voice_volume
