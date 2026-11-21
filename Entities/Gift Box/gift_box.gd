extends Area3D

@export var respawn_time: float = 0.5 ## The time in seconds it takes for the box to respawn.
@export var bob_intensity: float = 0.3 ## The height change of the bob animation in metres from the box's position.
@export var spin_rate: float = 2.5 ## How fast the box spins in radians per second.
@export var anim_speed: float = 1.0 ## How long it takes for a single loop of the animation tween.

@onready var timer = $Timer
@onready var gift_box_mesh: Node3D = $GiftBoxMesh

func _on_body_entered(body):
	if visible and body is Kart3D:
		visible = false
		body.item_handler.roll_item()
		timer.start(respawn_time)

func _on_timer_timeout():
	visible = true

func _ready() -> void:
	var tween = create_tween().set_loops().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(gift_box_mesh, "global_position", gift_box_mesh.global_position + Vector3(0, bob_intensity, 0), anim_speed)
	tween.tween_property(gift_box_mesh, "global_position", gift_box_mesh.global_position - Vector3(0, bob_intensity, 0), anim_speed)

func _physics_process(delta: float) -> void:
	gift_box_mesh.rotate_y(spin_rate * delta)
