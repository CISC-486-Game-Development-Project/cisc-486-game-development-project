## Singleton for managing music, sfx and voice lines.
extends Node3D

# Constants
const SYNC_ZERO_VOLUME: float = -60.0 ## The muted volume for when a sync track is not playing.
const SYNC_BASE_VOLUME: float = 0.0 ## The normal volume for when a sync track is playing.
const SYNC_FADE_TIME: float = 0.1 ## The time it takes to crossfade between sync tracks.

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

###################
## SFX Functions ##
###################

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

#####################
## Music Functions ##
#####################

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
	
	# Initialize first sync stream if applicable
	if current_music.stream is AudioStreamSynchronized:
		for i in range(current_music.stream.get_stream_count()):
			current_music.stream.set_sync_stream_volume(i, SYNC_ZERO_VOLUME)
		current_music.stream.set_sync_stream_volume(0, SYNC_BASE_VOLUME)
	
	# Add to scene and play music
	add_child(new_music)
	new_music.play()

## Stops currently playing backrgound music.
func stop_bgm() -> void:
	if current_music:
		current_music.queue_free()

## Changes the sync track if music is an AudioStreamSynchronized.
func change_sync_track(track_index: int = 0) -> void:
	if not current_music.stream is AudioStreamSynchronized:
		return # Only operate on AudioStreamSyncronized
	
	# Initialize variables
	var sync := current_music.stream as AudioStreamSynchronized
	var start_gains: Array[float] = []
	var target_gain := db_to_linear(SYNC_BASE_VOLUME)
	
	# Get start_gains from sync
	for i in range(sync.get_stream_count()):
		start_gains.append(db_to_linear(sync.get_sync_stream_volume(i)))
	
	# Tween the crossfade between tracks
	var tween := create_tween()
	tween.tween_method(
		func(time: float) -> void: # Lambda function for crossfading between sync stream tracks over time in a tween.
			for i in range(sync.get_stream_count()):
				var gain: float
				
				# Smoothly fade in with sin() and out with cos() depedning on which track is now active.
				if i == track_index:
					gain = target_gain * sin(time * PI * 0.5)
				else:
					gain = start_gains[i] * cos(time * PI * 0.5)
				
				# Avoid converting zero to -INF dB.
				sync.set_sync_stream_volume(i, linear_to_db(maxf(gain, 0.0001))),
		0.0, 1.0, SYNC_FADE_TIME
	)

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
