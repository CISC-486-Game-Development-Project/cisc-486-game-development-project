class_name RaceHandler
extends Node

signal position_changed(new_position)
signal lap_changed(new_lap)

@export var kart: Kart3D

var mostRecentlyPassed: Checkpoint
var nextMajorCheckpoint: Checkpoint
var lap: int: set = _set_lap
var position: int: set = _set_position

## Called when player has entered new_checkpoint.
## Updates mostRecentlyPassed if this checkpoint lines up with the player's nextMajorCheckpoint
## Updates nextMajorCheckpoint if this checkpoint is also a major checkpoint
## Returns true if mostRecentlyPassed is updated and false if not.
func entered_checkpoint(new_checkpoint: Checkpoint) -> bool:
	# TODO: Write this function
	return false

# Setters
func _set_position(new_position: int):
	if position == new_position:
		return
	position_changed.emit(new_position)
	position = new_position

func _set_lap(new_lap: int):
	lap_changed.emit(new_lap)
	lap = new_lap
