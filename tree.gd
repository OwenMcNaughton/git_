extends Node3D


var _area: Area3D = null


func _ready() -> void:
	$leaves_1.material_override = $leaves_1.material_override.duplicate()
	$leaves_2.material_override = $leaves_2.material_override.duplicate()
	$leaves_3.material_override = $leaves_3.material_override.duplicate()
	set_low_lod()
	add_to_group("trees")


func _process(delta: float) -> void:
	if _area != null:
		var gp = global_position - _area.global_position
		gp = Vector2(normalize(gp.x), normalize(gp.z))
		$leaves_1.material_override.set_shader_parameter("vignette_center", gp)
		$leaves_2.material_override.set_shader_parameter("vignette_center", gp)
		$leaves_3.material_override.set_shader_parameter("vignette_center", gp)


func normalize(value: float) -> float:
	var min_original: float = $Area3D/CollisionShape3D.shape.size.x * 0.5
	var max_original: float = -$Area3D/CollisionShape3D.shape.size.x * 0.5
	return (value - min_original) / (max_original - min_original)


func _on_area_3d_area_entered(area: Area3D) -> void:
	_area = area


func _on_area_3d_area_exited(area: Area3D) -> void:
	_area = null
	$leaves_1.material_override.set_shader_parameter("vignette_center", Vector2(100, 100))
	$leaves_2.material_override.set_shader_parameter("vignette_center", Vector2(100, 100))
	$leaves_3.material_override.set_shader_parameter("vignette_center", Vector2(100, 100))


func set_wind_rot(rads: float):
	$leaves_1.material_override.set_shader_parameter("rotation", rads)
	$leaves_2.material_override.set_shader_parameter("rotation", rads)
	$leaves_3.material_override.set_shader_parameter("rotation", rads)


func set_wind_strength(value: float, min: float, max: float):
	$leaves_1.material_override.set_shader_parameter("time_factor", value)
	$leaves_2.material_override.set_shader_parameter("time_factor", value)
	$leaves_3.material_override.set_shader_parameter("time_factor", value)
	
	$leaves_1.material_override.set_shader_parameter(
		"sway_frequency", Utils.remap(value, min, max, 1, 3))
	$leaves_2.material_override.set_shader_parameter(
		"sway_frequency", Utils.remap(value, min, max, 1, 3))
	$leaves_3.material_override.set_shader_parameter(
		"sway_frequency", Utils.remap(value, min, max, 1, 3))

	$leaves_1.material_override.set_shader_parameter(
		"sway_amplitude", Utils.remap(value, min, max, 0.01, 0.06))
	$leaves_2.material_override.set_shader_parameter(
		"sway_amplitude", Utils.remap(value, min, max, 0.03, 0.10))
	$leaves_3.material_override.set_shader_parameter(
		"sway_amplitude", Utils.remap(value, min, max, 0.05, 0.13))


func set_low_lod() -> void:
	$leaves_2.transparency = 0.0
	$leaves_3.transparency = 0.0
	$dirt.transparency = 0.0
	$leaves_2.cast_shadow = false
	$leaves_3.cast_shadow = false
	var tween_1 = get_tree().create_tween()
	tween_1.tween_property($leaves_2, "transparency", 1.0, 0.2)
	var tween_2 = get_tree().create_tween()
	tween_2.tween_property($leaves_3, "transparency", 1.0, 0.2)
	var tween_3 = get_tree().create_tween()
	tween_3.tween_property($dirt, "transparency", 1.0, 0.2)


func set_high_lod() -> void:
	$leaves_2.transparency = 1.0
	$leaves_3.transparency = 1.0
	$dirt.transparency = 1.0
	$leaves_2.visible = true
	$leaves_3.visible = true
	$dirt.visible = true
	$leaves_2.cast_shadow = false
	$leaves_3.cast_shadow = false
	var tween_1 = get_tree().create_tween()
	tween_1.tween_property($leaves_2, "transparency", 0.0, 0.2)
	var tween_2 = get_tree().create_tween()
	tween_2.tween_property($leaves_3, "transparency", 0.0, 0.2)
	var tween_3 = get_tree().create_tween()
	tween_3.tween_property($dirt, "transparency", 0.0, 0.2)
	tween_3.tween_callback(set_shadow_on)


func set_invisible() -> void:
	$leaves_2.visible = false
	$leaves_3.visible = false
	$dirt.visible = false


func set_shadow_on() -> void:
	$leaves_2.cast_shadow = true
	$leaves_3.cast_shadow = true
