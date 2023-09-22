extends Node3D


const x = preload("res://tree_big.png")


func _process(delta: float) -> void:
	$Control/fps.text = str(Engine.get_frames_per_second())
	$Control/trees.text = "Trees: %s" % str($trees.get_child_count())


func set_cam_size(size: float) -> void:
	$Control/cam_size.text = "SIZE: %s" % round(size)


func _ready():
	get_tree().root.use_occlusion_culling = true
	for x in range(-128, 128, 2):
		for y in range(-128, 128, 2):
			var spawn_loc: Vector3 = Vector3(x, 0, y)
			$trees.add_tree(spawn_loc)
