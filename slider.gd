extends PanelContainer


func _on_value_changed(value: float) -> void:
	$Label.text = str(value)


func _on_wind_rot_changed(value: float) -> void:
	print(get_tree().get_nodes_in_group("trees").size())
	for tree in get_tree().get_nodes_in_group("trees"):
		tree.set_wind_rot(-value)


func _on_arrow_changed(value: float) -> void:
	$arrow.rotation = value - deg_to_rad(90)


func _onwind_strength_changed(value: float) -> void:
	for tree in get_tree().get_nodes_in_group("trees"):
		tree.set_wind_strength(value, $HSlider.min_value, $HSlider.max_value)
