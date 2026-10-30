@tool
class_name Checkpoint
extends Area3D

@export var next_checkpoint: Checkpoint ## Checkpoint the player should pass after this one
@export var major: bool ## Major checkpoints are mandatory and determine lap count
@export var width: float = 30 ## Collider's width

var next_major_checkpoint: Checkpoint ## Next major checkpoint excluding this one
var checkpoint_index: int ## This orders the checkpoints, starting line is 0, its next_checkpoint is 1, so on.
var boundary_plane: Plane

@onready var collision_shape = $CollisionShape3D

func _ready():
	var tempnext_checkpoint : Checkpoint = next_checkpoint
	while !tempnext_checkpoint.major:
		tempnext_checkpoint = tempnext_checkpoint.next_checkpoint
	next_major_checkpoint = tempnext_checkpoint
	boundary_plane = Plane(-collision_shape.global_basis.z, collision_shape.global_position)
	collision_shape.shape.size.x = width

func _process(_delta):
	if Engine.is_editor_hint():
		if collision_shape and collision_shape.shape.size.x != width:
			collision_shape.shape = collision_shape.shape.duplicate()
			collision_shape.shape.size.x = width

func _on_body_entered(body: Node3D):
	if not body is Kart3D:
		return false
	var kart = body as Kart3D
	if kart.race_handler: # I think this will only be false if a kart starts in a checkpoint, nothing needs to happen in that case
		kart.race_handler.entered_checkpoint(self)
