class_name Wrench
extends CharacterBody3D

# Export Vars
@export_group("Functionality")
@export var model: ItemModel
@export var speed: float = 40.0
@export var max_velocity: float = 40.0
@export var lifetime: float = 10.0
@export var thrower_immunity_time: float = 1.0
@export var max_bounces: int = 5
@export var time_between_increments: float = 0.2

@export_group("Falling")
@export var fall_velocity: float = -100.0 ## Speed of falling.
@export var fall_gravity: float = 20.0 ## Intensity of gravitational force.

# Onready Vars
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var life_timer: Timer = $LifeTimer
@onready var movement_state_machine: StateMachine = $MovementStateMachine
@onready var destructible: Destructible = $Destructible

# Internal Vars
var hitbox: Hitbox
var bounces: int
var time_before_bounce: float

func _ready() -> void:
	# Start life timer and connect it to free on timeout
	life_timer.timeout.connect(destructible._destroy)
	life_timer.start(lifetime)
	time_before_bounce = time_between_increments

func _physics_process(_delta: float) -> void:
	# Go forward at speed if on ground
	if velocity.length() < (Vector3.FORWARD * max_velocity).length():
		velocity += -global_basis.z * speed
	model.rotate_y(PI/20)
	if time_before_bounce > 0.0:
		time_before_bounce -= _delta
	
	var is_colliding = move_and_slide()
	
	if is_colliding:
		if is_on_wall():
			var collision = get_last_slide_collision()
			
			# Face toward normal of collision to bounce off
			rotate_y(-global_basis.z.angle_to(collision.get_normal()))
			#velocity.bounce(collision.get_normal())
			
			if time_before_bounce <= 0.0:
				# Add to bounces and free if too many bounces
				time_before_bounce = time_between_increments
				bounces += 1
				if bounces >= max_bounces:
					destructible._destroy()
