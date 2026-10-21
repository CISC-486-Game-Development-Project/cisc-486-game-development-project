extends Node

@export var boost_time: float = 1.0
@export var ignore_offroad: bool = true

func consume(kart: Kart3D) -> void:
	kart.set_boost(Boost.new(boost_time, ignore_offroad))
