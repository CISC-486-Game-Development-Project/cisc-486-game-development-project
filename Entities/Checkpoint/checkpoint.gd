class_name Checkpoint
extends Area3D

@export var nextCheckpoint: Checkpoint ## Checkpoint the player should pass after this one
@export var major: bool ## Major checkpoints are mandatory and determine lap count

var nextMajorCheckpoint: Checkpoint ## Next major checkpoint excluding this one
var checkpointIndex: int ## This orders the checkpoints, starting line is 0, its nextCheckpoint is 1, so on.

func _ready():
	# TODO: Calculate nextMajorCheckpoint by traversing until you find it
	pass

func _on_body_entered(body: Node3D):
	if body != Kart3D:
		return false
	var kart = body as Kart3D
	kart.race_handler.entered_checkpoint(self)
