extends Node3D


const agent_scene = preload("res://agent.tscn")
var occluders: int = 0


func _process(delta: float) -> void:
	$Control/fps.text = "FPS: %s" % str(Engine.get_frames_per_second())
	# Engine.get_
	$Control/trees.text = "Trees: %s" % str($NavigationRegion3D/trees.get_child_count())
	$Control/occluders.text = "Occluders: %s" % str(occluders)
	occluders = 0


func set_cam_size(size: float) -> void:
	$Control/cam_size.text = "CAM SIZE: %s" % round(size)


func _ready() -> void:
	for x in range(32):
		for y in range(32):
			var spawn_loc: Vector3 = Vector3(
				Utils.remap(x, 0, 32, -16, 16), 
				0, 
				Utils.remap(y, 0, 32, -16, 16)
			)
			$NavigationRegion3D/trees.add_tree(spawn_loc)
	$NavigationRegion3D.bake_navigation_mesh()


func _on_navigation_region_3d_bake_finished() -> void:
	for _i in range(2000):
		var agent = agent_scene.instantiate()
		agent.position = Vector3(Utils.randf_range(-10, 10), .1, Utils.randf_range(-10, 10))
		agent.activated = true
		agent.path.connect(give_agent_path)
		$agents.add_child(agent)


func give_agent_path(agent: Agent) -> void:
	var targets = $NavigationRegion3D/trees.get_children()
	var target = targets[randi() % targets.size()]
	agent.goto(target)
