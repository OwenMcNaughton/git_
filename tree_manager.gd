extends Node3D


const t = preload("res://tree.tscn")

		
func add_tree(pos: Vector3) -> void:
	var tree = t.instantiate()
	tree.position = pos
	tree.rotation.y = Utils.randf_range(-100, 100)
	add_child(tree)
