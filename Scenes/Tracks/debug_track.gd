extends Node3D

@export var track_music: AudioStream ## Music to play while on this track.

func _ready() -> void:
	AudioManager.change_bgm(track_music)
