extends Node


var rng = RandomNumberGenerator.new()


func remap(value, old_min, old_max, new_min, new_max):
	return new_min + ((value - old_min) / (old_max - old_min)) * (new_max - new_min)


func randf_range(min: float, max: float) -> float:
	return rng.randf_range(min, max)
