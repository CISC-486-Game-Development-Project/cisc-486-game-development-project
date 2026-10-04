## A class that stores information regarding a kart's model.
class_name KartModel
extends Node3D

@export var body: Node3D ## The body of the kart model.
@export var wheels: Array[Wheel] ## An array of all wheels in the kart model.
@export var hurtbox: Hurtbox ## The hurtbox of the kart model used for hit detection.
@export var collision_shape_3d: CollisionShape3D ## The shape of the model used for collisions.
