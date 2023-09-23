extends Node3D


class_name OakTree


var _occluders: Array[Area3D] = []
var _centers: Array[Vector2] = []
@onready var collision: CollisionShape3D = $Area3D/CollisionShape3D
@onready var my_root = get_parent().get_parent().get_parent()
@onready var l1 = $leaves_1
@onready var l2 = $leaves_2
@onready var l3 = $leaves_3


func _ready() -> void:
	$leaves_1.material_override = $leaves_1.material_override.duplicate()
	$leaves_2.material_override = $leaves_2.material_override.duplicate()
	$leaves_3.material_override = $leaves_3.material_override.duplicate()
	set_low_lod()
	
	$leaves_1.material_override.set_shader_parameter("rotation", 90 - rotation.y)
	$leaves_2.material_override.set_shader_parameter("rotation", 90 - rotation.y)
	$leaves_3.material_override.set_shader_parameter("rotation", 90 - rotation.y)
	
	var to = Utils.randf_range(0.8, 1.2)
	$leaves_1.material_override.set_shader_parameter("time_offset", to)
	$leaves_2.material_override.set_shader_parameter("time_offset", to) 
	$leaves_3.material_override.set_shader_parameter("time_offset", to)
	
	add_to_group("trees")


func _process(delta: float) -> void:
	_centers = []
	for area in _occluders:
		var gp = global_position - area.global_position
		var s = collision.shape.size
		gp = Vector2(
			Utils.normalize(gp.x, s.x * 0.5, -s.x * 0.5),
			Utils.normalize(gp.z, s.z * 0.5, -s.z * 0.5)
		)
		gp = rotate_around_center(gp, Vector2(0.5, 0.5), rotation.y)
		_centers.append(gp)
		my_root.occluders += 1
	l1.material_override.set_shader_parameter("vignette_centers", _centers)
	l2.material_override.set_shader_parameter("vignette_centers", _centers)
	l3.material_override.set_shader_parameter("vignette_centers", _centers)


func rotate_around_center(point: Vector2, center: Vector2, angle: float) -> Vector2:
	var s = sin(angle)
	var c = cos(angle)
	point -= center
	var xnew = point.x * c - point.y * s
	var ynew = point.x * s + point.y * c
	point.x = xnew + center.x
	point.y = ynew + center.y
	return point


func _on_area_3d_area_entered(area: Area3D) -> void:
	_occluders.append(area)


func _on_area_3d_area_exited(area: Area3D) -> void:
	_occluders.erase(area)
	$leaves_1.material_override.set_shader_parameter("vignette_center", Vector2(100, 100))
	$leaves_2.material_override.set_shader_parameter("vignette_center", Vector2(100, 100))
	$leaves_3.material_override.set_shader_parameter("vignette_center", Vector2(100, 100))


func set_wind_rot(rads: float):
	$leaves_1.material_override.set_shader_parameter("rotation", rads - rotation.y)
	$leaves_2.material_override.set_shader_parameter("rotation", rads - rotation.y)
	$leaves_3.material_override.set_shader_parameter("rotation", rads - rotation.y)


func set_wind_strength(value: float, min: float, max: float):
	$leaves_1.material_override.set_shader_parameter("time_factor", value)
	$leaves_2.material_override.set_shader_parameter("time_factor", value)
	$leaves_3.material_override.set_shader_parameter("time_factor", value)
	
	$leaves_1.material_override.set_shader_parameter(
		"sway_frequency", Utils.remap(value, min, max, 0.1, 3))
	$leaves_2.material_override.set_shader_parameter(
		"sway_frequency", Utils.remap(value, min, max, 0.1, 3))
	$leaves_3.material_override.set_shader_parameter(
		"sway_frequency", Utils.remap(value, min, max, 0.1, 3))

	$leaves_1.material_override.set_shader_parameter(
		"sway_amplitude", Utils.remap(value, min, max, 0.01, 0.06))
	$leaves_2.material_override.set_shader_parameter(
		"sway_amplitude", Utils.remap(value, min, max, 0.03, 0.10))
	$leaves_3.material_override.set_shader_parameter(
		"sway_amplitude", Utils.remap(value, min, max, 0.05, 0.15))


func set_low_lod() -> void:
	$leaves_2.transparency = 0.0
	$leaves_3.transparency = 0.0
	$dirt.transparency = 0.0
	$leaves_1.cast_shadow = false
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
