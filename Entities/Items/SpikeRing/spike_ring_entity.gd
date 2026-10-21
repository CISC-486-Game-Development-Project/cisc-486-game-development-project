extends Node3D

# Constants
const SPIN_SPEED: float = 2.0

# Export Vars
@export var lifetime: float = 10.0
@export var hitbox: Hitbox

# Onready Vars
@onready var spike_ring_mesh: MeshInstance3D = $SpikeRingMesh
@onready var life_timer: Timer = $LifeTimer

func _ready() -> void:
	# Start life timer and connect it to free on timeout
	life_timer.timeout.connect(queue_free)
	life_timer.start(lifetime)

func _physics_process(delta: float) -> void:
	# Spin ring around
	spike_ring_mesh.rotate_y(-SPIN_SPEED * delta)
