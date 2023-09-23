using Godot;
using System;

public partial class main : Node3D
{

	private PackedScene tree_scene = ResourceLoader.Load<PackedScene>("res://tree.tscn");
	private PackedScene agent_scene = ResourceLoader.Load<PackedScene>("res://agent.tscn");
	public float occluders;

	public override void _Ready()
	{
		int max = 64;
		for (int i = 0; i < max; i++)
    {
			for (int j = 0; j < max; j++)
      {
				Vector3 spawn_loc = new Vector3(
					remap(i, 0, max, -32, 32),
					0,
					remap(j, 0, max, -32, 32)
				);
				add_tree(spawn_loc);
			}
    }
		GetNode<NavigationRegion3D>("NavigationRegion3D").BakeNavigationMesh();
	}

	public override void _Process(double delta)
	{
		GetNode<Label>("Control/fps").Text = "FPS: " + Engine.GetFramesPerSecond().ToString();
		GetNode<Label>("Control/trees").Text = "Trees: " + GetNode<Node3D>("NavigationRegion3D/trees").GetChildCount().ToString();
	}

	public void set_cam_size(float size)
  {
		GetNode<Label>("Control/cam_size").Text = "Cam Size: " + Math.Round(size).ToString();

	}

	private float remap(float value, float old_min, float old_max, float new_min, float new_max)
	{
		return new_min + ((value - old_min) / (old_max - old_min)) * (new_max - new_min);
	}

	private void add_tree(Vector3 spawn_loc)
  {
		tree tree = (tree)tree_scene.Instantiate();
		tree.Position = spawn_loc;
		tree.Rotation = new Vector3(tree.Rotation.X, GD.Randf() * 100.0f, tree.Rotation.Z);
		GetNode<Node3D>("NavigationRegion3D/trees").AddChild(tree);
	}

	public void _on_navigation_region_3d_bake_finished()
  {
		for (int i = 0; i < 1000; i++)
    {
			agent agent = (agent)agent_scene.Instantiate();
			agent.Position = new Vector3(-10.0f + GD.Randf() * (20.0f), 0.1f, -10.0f + GD.Randf() * (20.0f));
			agent.activated = true;
			Action myAction = () => { give_agent_path(agent); };
			agent.Connect("path", Callable.From(myAction));
		}
  }

	private void give_agent_path(agent agent)
  {
		Godot.Collections.Array<Godot.Node> targets = GetNode<Node3D>("NavigationRegion3D/trees").GetChildren();
		Random rnd = new Random();
		Node3D target = (Node3D)targets[rnd.Next(targets.Count)];
		agent.go_to(target);
  }
}
