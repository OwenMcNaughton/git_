extends Node3D


class_name OakTree


var _occluders: Array[Area3D] = []
var _centers: Array[Vector2] = []
@onready var collision: CollisionShape3D = $Area3D/CollisionShape3D
@onready var my_root = get_parent().get_parent().get_parent()
@onready var l1 = $leaves_1
@onready var l2 = $leaves_2
@onready var l3 = $leaves_3

var bot_a = preload("res://tree_big.png")
var mid_a = preload("res://tree_small.png")
var top_a = preload("res://tree_tiny.png")
var bot_b = preload("res://bot_b.png")
var mid_b = preload("res://mid_b.png")
var top_b = preload("res://top_b.png")
var bot_c = preload("res://bot_c.png")
var mid_c = preload("res://mid_c.png")
var top_c = preload("res://top_c.png")
var bot_d = preload("res://bot_d.png")
var mid_d = preload("res://mid_d.png")
var top_d = preload("res://top_d.png")
var bot_e = preload("res://bot_e.png")
var mid_e = preload("res://mid_e.png")
var top_e = preload("res://top_e.png")


func _ready() -> void:
	set_graphics("original")
	
	$leaves_1.material_override = $leaves_1.material_override.duplicate()
	$leaves_2.material_override = $leaves_2.material_override.duplicate()
	$leaves_3.material_override = $leaves_3.material_override.duplicate()
	set_low_lod()
	
	$leaves_1.material_override.set_shader_parameter("rotation", 90 - rotation.y)
	$leaves_2.material_override.set_shader_parameter("rotation", 90 - rotation.y)
	$leaves_3.material_override.set_shader_parameter("rotation", 90 - rotation.y)
	
	var to = Utils.randf_range(0.1, 1.9)
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
	$leaves_1.cast_shadow = true
	$leaves_2.cast_shadow = true
	$leaves_3.cast_shadow = true


func set_graphics(option: String):
	match option:
		"original": 
			$leaves_1.material_override.set_shader_parameter("image_texture", bot_a)
			$leaves_2.material_override.set_shader_parameter("image_texture", mid_a)
			$leaves_3.material_override.set_shader_parameter("image_texture", top_a)
		"speed_tree": 
			$leaves_1.material_override.set_shader_parameter("image_texture", bot_b)
			$leaves_2.material_override.set_shader_parameter("image_texture", mid_b)
			$leaves_3.material_override.set_shader_parameter("image_texture", top_b)
		"speed_tree_expanded": 
			$leaves_1.material_override.set_shader_parameter("image_texture", bot_c)
			$leaves_2.material_override.set_shader_parameter("image_texture", mid_c)
			$leaves_3.material_override.set_shader_parameter("image_texture", top_c)
		"speed_tree_grayscale": 
			$leaves_1.material_override.set_shader_parameter("image_texture", bot_d)
			$leaves_2.material_override.set_shader_parameter("image_texture", mid_d)
			$leaves_3.material_override.set_shader_parameter("image_texture", top_d)
		"speed_tree_greenscale": 
			$leaves_1.material_override.set_shader_parameter("image_texture", bot_e)
			$leaves_2.material_override.set_shader_parameter("image_texture", mid_e)
			$leaves_3.material_override.set_shader_parameter("image_texture", top_e)
