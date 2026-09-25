## A hitlog class for hit detection. Useful for only registering one hit from a multi-hitbox attack.
class_name HitLog
extends RefCounted

var hit_log: Array = [] ## Array containing logged hits

## Returns true if given node has been logged.
func has_hit(node: Node) -> bool:
	return hit_log.has(node)

## Adds given node to hit log.
func log_hit(node: Node) -> void:
	hit_log.append(node)
