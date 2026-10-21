class_name ConsumableItem
extends Item

@export var is_boost: bool
@export var boost_time: float
@export var ignore_offroad: bool

func use(kart: Kart3D) -> void:
	if is_boost:
		kart.set_boost(Boost.new(boost_time, ignore_offroad))
