extends Node3D


var _area: Area3D = null


func _ready() -> void:
	add_to_group("trees")


func _process(delta: float) -> void:
	if _area != null:
		var gp = global_position - _area.global_position
		gp = Vector2(normalize(gp.x), normalize(gp.z))
		$bottom_leaves.material_override.set_shader_parameter("vignette_center", gp)
		$top_leaves.material_override.set_shader_parameter("vignette_center", gp)


func normalize(value: float) -> float:
	var min_original: float = $Area3D/CollisionShape3D.shape.size.x * 0.5
	var max_original: float = -$Area3D/CollisionShape3D.shape.size.x * 0.5
	return (value - min_original) / (max_original - min_original)


func _on_area_3d_area_entered(area: Area3D) -> void:
	_area = area


func _on_area_3d_area_exited(area: Area3D) -> void:
	_area = null
	$bottom_leaves.material_override.set_shader_parameter("vignette_center", Vector2(100, 100))
	$top_leaves.material_override.set_shader_parameter("vignette_center", Vector2(100, 100))


func set_wind_rot(rads: float):
	$bottom_leaves.material_override.set_shader_parameter("rotation", rads)
	$top_leaves.material_override.set_shader_parameter("rotation", rads)


func set_wind_strength(value: float, min: float, max: float):
	$bottom_leaves.material_override.set_shader_parameter("time_factor", value)
	$top_leaves.material_override.set_shader_parameter("time_factor", value)
	
	$bottom_leaves.material_override.set_shader_parameter(
		"sway_frequency", Utils.remap(value, min, max, 1, 3))
	$top_leaves.material_override.set_shader_parameter(
		"sway_frequency", Utils.remap(value, min, max, 1, 3))

	$bottom_leaves.material_override.set_shader_parameter(
		"sway_amplitude", Utils.remap(value, min, max, 0.02, 0.06))
	$top_leaves.material_override.set_shader_parameter(
		"sway_amplitude", Utils.remap(value, min, max, 0.06, 0.10))
