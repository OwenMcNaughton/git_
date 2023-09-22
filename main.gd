extends Node3D


func _process(delta: float) -> void:
	$Control/fps.text = str(Engine.get_frames_per_second())
	$Control/trees.text = "Trees: %s" % str($trees.get_child_count())


func set_cam_size(size: float) -> void:
	$Control/cam_size.text = "SIZE: %s" % round(size)
