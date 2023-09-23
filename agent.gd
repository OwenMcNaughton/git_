extends Node3D


class_name Agent


@onready var navigation_agent: NavigationAgent3D = $NavigationAgent3D
@onready var anim_player: AnimationPlayer = $AnimationPlayer
var activated = false


signal path(agent: Agent)


func _ready() -> void:
	navigation_agent.path_desired_distance = 0.5
	navigation_agent.target_desired_distance = 0.5
	anim_player.play("walking")


func goto(target):
	navigation_agent.set_target_position(target.global_position)


func _process(delta):
	if activated and navigation_agent.is_navigation_finished():
		emit_signal("path", self)

	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = navigation_agent.get_next_path_position()

	var new_velocity: Vector3 = next_path_position - current_agent_position
	new_velocity = new_velocity.normalized()
	new_velocity = new_velocity * 0.25

	var opposite_direction: Vector3 = current_agent_position - next_path_position
	var target_position_for_reverse_look: Vector3 = current_agent_position + opposite_direction.normalized()

	look_at(target_position_for_reverse_look, Vector3(0.01, 1, 0.01))

	position += new_velocity * delta


func init(i):
	$Area3D.name = str(i)
