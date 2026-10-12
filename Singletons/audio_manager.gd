## Singleton for managing music, sfx and voice lines.
extends Node3D

# Constants
const SYNC_ZERO_VOLUME: float = -60.0 ## The muted volume for when a sync track is not playing.
const SYNC_BASE_VOLUME: float = 0.0 ## The normal volume for when a sync track is playing.
const DEFAULT_CROSSFADE_TIME: float = 0.1 ## The default time it takes to crossfade between tracks.

# Enums
enum SoundType {
	SFX, ## Used when creating a new sound effect.
	VOICE ## Used when creating a new voice line.
}

# Internal Vars
var current_music: AudioStreamPlayer
var current_sync_index: int
var current_sfx: Array = []
var current_voices: Array = []

var master_volume: float = 0.75
var music_volume: float = 0.75
var sfx_volume: float = 0.75
var voice_volume: float = 0.75

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
	new_sound.finished.connect(_erase_sound.bind(new_sound))
	
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
	new_sound.finished.connect(_erase_sound.bind(new_sound))
	
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
	new_sound.finished.connect(_erase_sound.bind(new_sound))
	
	# Add to parent node and play sound
	parent.add_child(new_sound)
	new_sound.play()

## Called when a sound is finished to remove it from the stored sound arrays and free the node playing the sound.
func _erase_sound(sound: Node) -> void:
	if sound in current_sfx:
		current_sfx.erase(sound)
	elif sound in current_voices:
		current_voices.erase(sound)
	sound.queue_free()

#####################
## Music Functions ##
#####################

## Changes the background music to a specified track.
func change_bgm(music: AudioStream, crossfade: bool = true, force_restart: bool = false, crossfade_time: float = DEFAULT_CROSSFADE_TIME) -> void:
	# Don't change bgm if music is the same as current_music unless force_restart is true
	if current_music and not force_restart:
		if current_music.stream == music:
			return
	
	# Initialize variables
	var old_music := current_music
	var target_volume := master_volume * music_volume
	
	# Set up new_music
	var new_music := AudioStreamPlayer.new()
	new_music.stream = music
	new_music.process_mode = Node.PROCESS_MODE_ALWAYS # Ensure playback while paused
	new_music.volume_linear = 0.0 if crossfade and old_music else target_volume
	
	# Initialize first sync stream if applicable
	if new_music.stream is AudioStreamSynchronized:
		var sync := new_music.stream as AudioStreamSynchronized
		for i in range(sync.get_stream_count()):
			sync.set_sync_stream_volume(i, SYNC_ZERO_VOLUME)
		sync.set_sync_stream_volume(0, SYNC_BASE_VOLUME)
		current_sync_index = 0
	
	# Add to scene, play music, and set as current_music
	add_child(new_music)
	new_music.play()
	current_music = new_music
	
	# Handle transition between old and new music
	if crossfade and old_music:
		var old_volume := old_music.volume_linear
		var fade_tween := create_tween()
		
		# Tween the crossfade between tracks
		fade_tween.tween_method(
			func(time: float) -> void: # Lambda function for crossfading between streams over time in a tween.
				old_music.volume_linear = old_volume * cos(time * PI * 0.5)
				new_music.volume_linear = target_volume * sin(time * PI * 0.5),
			0.0, 1.0, crossfade_time
		)
		fade_tween.tween_callback(old_music.queue_free) # Free old_music once crossfade is finished
	elif old_music:
		old_music.queue_free() # Free old_music if it exists after bgm changed

## Stops currently playing backrgound music.
func stop_bgm() -> void:
	if current_music:
		current_music.queue_free()

## Stops all currently playing sfx & voices.
func stop_all_sounds() -> void:
	for sfx in current_sfx:
		_erase_sound(sfx)
	for voice in current_voices:
		_erase_sound(voice)

## Changes the sync track if music is an AudioStreamSynchronized.
func change_sync_track(track_index: int = 0, crossfade_time: float = DEFAULT_CROSSFADE_TIME) -> void:
	# Only operate on AudioStreamSyncronized
	if not current_music.stream is AudioStreamSynchronized:
		return
	
	# Do nothing if track_index is already the current_sync_index
	if track_index == current_sync_index:
		return
	current_sync_index = track_index
	
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
		0.0, 1.0, crossfade_time
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
	if current_music:
		current_music.volume_linear = master_volume * music_volume
	
	# Update sfx volumes
	for sfx in current_sfx:
		sfx.volume_linear = master_volume * sfx_volume
	
	# Update voice volumes
	for voice in current_voices:
		voice.volume_linear = master_volume * voice_volume
