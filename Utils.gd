extends Node


func remap(value, old_min, old_max, new_min, new_max):
	return new_min + ((value - old_min) / (old_max - old_min)) * (new_max - new_min)
