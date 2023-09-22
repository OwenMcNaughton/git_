extends Node3D


const t = preload("res://tree.tscn")

		
func add_tree(pos: Vector3) -> void:
	var tree = t.instantiate()
	tree.position = pos
	add_child(tree)
