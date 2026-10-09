## A hitbox class for hit detection. Can be intsantiated.
class_name Hitbox
extends Area3D

signal on_hit(area) ## A signal used to broadcast when this hitbox hits.

@export var hitbox_lifetime: float ## The time in seconds this hitbox is active. If not set, hitbox will be active forever.
var shape: Shape3D ## The shape to be set as this hitbox's collision shape.
var hit_log: HitLog ## The hitlog this hitbox is associated with. Optional, only useful for ensuring only one hit is registered from multi-hitbox attacks.

func _init(_hitbox_lifetime: float = 0.0, _shape: Shape3D = null, _hit_log: HitLog = null) -> void:
	if _hitbox_lifetime != 0.0:
		hitbox_lifetime = _hitbox_lifetime
	if _shape:
		shape = _shape
	if _hit_log:
		hit_log = _hit_log

func _ready() -> void:
	monitorable = false
	area_entered.connect(_on_area_entered)
	
	if hitbox_lifetime > 0.0:
		var new_timer = Timer.new()
		add_child(new_timer)
		new_timer.timeout.connect(queue_free)
		new_timer.call_deferred("start", hitbox_lifetime)
	
	if shape:
		var collision_shape = CollisionShape3D.new()
		collision_shape.shape = shape
		add_child(collision_shape)

## Called when this hitbox detects an area.
func _on_area_entered(area: Area3D) -> void:
	if not area is Hurtbox:
		return

	# Hit logging to prevent duplicate hits from the same attack
	var hurtbox_owner = area.owner
	if hit_log:
		if hit_log.has_hit(hurtbox_owner):
			return
		else:
			hit_log.log_hit(hurtbox_owner)
	
	on_hit.emit(area)
	area.recieve_hit(get_parent())
