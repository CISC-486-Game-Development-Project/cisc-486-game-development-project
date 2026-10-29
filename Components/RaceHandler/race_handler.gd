class_name RaceHandler
extends Node

signal position_changed(new_position)
signal lap_changed(new_lap)
signal finished ## Kart has completed all laps

@export var kart: Kart3D

var mostRecentlyPassed: Checkpoint
var next_checkpoint_plane: Plane
var nextMajorCheckpoint: Checkpoint
var lap: int = 1: set = _set_lap
var race_laps: int ## Read only, assigned by the track
var position: int = -1: set = _set_position
var distance_to_next_checkpoint: float
var is_finished := false

## Called when player has entered new_checkpoint.
## Updates mostRecentlyPassed if this checkpoint lines up with the player's nextMajorCheckpoint
## Updates nextMajorCheckpoint if this checkpoint is also a major checkpoint
## Returns true if mostRecentlyPassed is updated and false if not.
func entered_checkpoint(new_checkpoint: Checkpoint) -> bool:
	if is_finished:
		return false
	if new_checkpoint.major:
		if new_checkpoint != nextMajorCheckpoint:
			return false
		nextMajorCheckpoint = new_checkpoint.nextMajorCheckpoint
		if new_checkpoint.checkpointIndex == 0: # If this is the starting line
			if kart.race_handler.lap >= race_laps:
				# kart has finished the race
				finished.emit()
				is_finished = true
				# TODO: this should be visually shown in some way
			else:
				lap += 1
	elif new_checkpoint.nextMajorCheckpoint.checkpointIndex > nextMajorCheckpoint.checkpointIndex:
		return false
	mostRecentlyPassed = new_checkpoint
	next_checkpoint_plane = mostRecentlyPassed.nextCheckpoint.boundary_plane
	return true
	
	#TODO: Update distance to next checkpoint each frame.
func _process(_delta: float) -> void:
	distance_to_next_checkpoint = next_checkpoint_plane.distance_to(kart.global_position)
	pass

# Setters
func _set_position(new_position: int):
	if position == new_position:
		return
	position_changed.emit(new_position)
	position = new_position

func _set_lap(new_lap: int):
	lap_changed.emit(new_lap)
	lap = new_lap
