class_name Shell
extends CharacterBody3D

# Export Vars
@export var model: ItemModel
@export var speed: float = 20.0
@export var max_velocity: float = 20.0
@export var lifetime: float = 10.0
@export var thrower_immunity_time: float = 1.0
@export var max_bounces: int = 5

# Onready Vars
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var life_timer: Timer = $LifeTimer
@onready var movement_state_machine: StateMachine = $MovementStateMachine

# Internal Vars
var hitbox: Hitbox
var bounces: int

func _ready() -> void:
	# Set up hitbox
	hitbox = model.hitbox
	hitbox.on_hit.connect(_on_hit)
	
	# Start life timer and connect it to free on timeout
	life_timer.timeout.connect(queue_free)
	life_timer.start(lifetime)

func _physics_process(_delta: float) -> void:
	# Go forward at speed if on ground
	if velocity.length() < (Vector3.FORWARD * max_velocity).length():
		velocity += -global_basis.z * speed
	model.rotate_y(PI/20)
	
	var is_colliding = move_and_slide()
	
	if is_colliding:
		if is_on_wall():
			var collision = get_last_slide_collision()
			
			# Face toward normal of collision to bounce off
			rotate_y(-global_basis.z.angle_to(collision.get_normal()))
			
			# Add to bounces and free if too many bounces
			bounces += 1
			if bounces >= max_bounces:
				queue_free()

## Called when this object is hit.
func _on_hit(_hitter_hitbox: Hitbox) -> void:
	queue_free()
