extends Node3D


var spawn_loc: Vector3 = Vector3(-86, 0, -48)
const t = preload("res://tree.tscn")


func _process(delta: float) -> void:
	for _i in range(10):
		if spawn_loc.z > 48:
			return
		spawn_loc.x += 4
		if spawn_loc.x >= 84:
			spawn_loc.x = -86
			spawn_loc.z += 4

		var tree = t.instantiate()
		tree.position = spawn_loc
		add_child(tree)
