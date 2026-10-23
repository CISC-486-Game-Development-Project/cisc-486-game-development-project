extends Area3D

var karts: Array[Kart3D]
var bodies: Array[Node3D]

func _on_body_entered(body: Node3D) -> void:
	if body is Kart3D:
		karts.append(body)
	else:
		bodies.append(body)

func _on_body_exited(body: Node3D) -> void:
	if body is Kart3D:
		if body in karts:
			karts.erase(body)
	else:
		if body in bodies:
			bodies.erase(body)
