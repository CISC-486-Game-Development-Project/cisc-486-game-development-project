extends CharacterBody3D

# Export Vars
@export var model: ItemModel
@export var speed: float = 20.0
@export var lifetime: float = 10.0

# Onready Vars
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D
@onready var life_timer: Timer = $LifeTimer

# Internal Vars
var hitbox: Hitbox

func _ready() -> void:
	# Set up hitbox
	hitbox = model.hitbox
	
	# Start life timer and connect it to free on timeout
	life_timer.timeout.connect(queue_free)
	life_timer.start(lifetime)

func _physics_process(_delta: float) -> void:
	# Go forward at speed
	velocity = -global_basis.z * speed
	move_and_slide()
