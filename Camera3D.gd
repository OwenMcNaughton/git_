extends Camera3D

var zoom_speed: float = .05
@export var min_zoom: float = 2
@export var max_zoom: float = 200
var friction: float = 0.9
var zoom_velocity: float = 0.0
var position_velocity: Vector3 = Vector3()

var is_panning: bool = false


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var bi = event.button_index
		if bi == MouseButton.MOUSE_BUTTON_WHEEL_UP or bi == MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
			_handle_zoom(event)
		elif bi == MouseButton.MOUSE_BUTTON_MIDDLE:
			is_panning = event.pressed
	elif event is InputEventMouseMotion and is_panning:
		_handle_pan(event)


func _handle_zoom(event: InputEvent) -> void:
	var viewport_size = get_viewport().size
	var mouse_pos = event.position
	var rel_mouse_pos = Vector2(mouse_pos.x / viewport_size.x - 0.5, mouse_pos.y / viewport_size.y - 0.5)
	
	var scaled_zoom_speed = zoom_speed * (1.0 + log(size) * 2)
	
	
	var x_translate = rel_mouse_pos.x * scaled_zoom_speed * viewport_size.x / viewport_size.y
	var y_translate = rel_mouse_pos.y * scaled_zoom_speed

	if event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_UP:
		if size > min_zoom:
			zoom_velocity -= scaled_zoom_speed
			position_velocity += Vector3(x_translate, 0, y_translate)
	elif event.button_index == MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
		if size < max_zoom:
			zoom_velocity += scaled_zoom_speed
			position_velocity += Vector3(-x_translate, 0, -y_translate)

	size = clamp(size, min_zoom, max_zoom)


func _process(delta: float) -> void:
	var old_size = size
	
	size += zoom_velocity
	size = clamp(size, min_zoom, max_zoom)
	
	var zoom_fraction = (size - old_size) / zoom_velocity if zoom_velocity != 0 else 1
	
	global_translate(position_velocity * zoom_fraction)

	zoom_velocity *= friction
	position_velocity *= friction

	if zoom_velocity < 0.001 and zoom_velocity > -0.001:
		zoom_velocity = 0.0
	if position_velocity.length() < 0.001:
		position_velocity = Vector3()


func _handle_pan(event: InputEventMouseMotion) -> void:
	var viewport_size = get_viewport().size
	var aspect_ratio: float = viewport_size.x / float(viewport_size.y)

	var pan_factor_x = size / viewport_size.x * aspect_ratio
	var pan_factor_y = size / viewport_size.y
	
	var pan_x = event.relative.x * pan_factor_x / 10
	var pan_y = event.relative.y * pan_factor_y / 10
	
	position_velocity += Vector3(-pan_x, 0, -pan_y)
