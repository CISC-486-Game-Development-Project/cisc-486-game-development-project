class_name Boost
extends RefCounted

var boost_time: float = 0.0
var ignore_offroad: bool = false

func _init(_boost_time: float = 0.0, _ignore_offroad: bool = false) -> void:
	boost_time = _boost_time
	ignore_offroad = _ignore_offroad
