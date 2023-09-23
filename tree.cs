using Godot;
using System;
using System.Collections.Generic;

public partial class tree : Node3D
{

	private Texture2D bot_a = ResourceLoader.Load<Texture2D>("res://tree_big.png");
	private Texture2D mid_a = ResourceLoader.Load<Texture2D>("res://tree_small.png");
	private Texture2D top_a = ResourceLoader.Load<Texture2D>("res://tree_tiny.png");
	private Texture2D bot_b = ResourceLoader.Load<Texture2D>("res://bot_b.png");
	private Texture2D mid_b = ResourceLoader.Load<Texture2D>("res://mid_b.png");
	private Texture2D top_b = ResourceLoader.Load<Texture2D>("res://top_b.png");
	private Texture2D bot_c = ResourceLoader.Load<Texture2D>("res://bot_c.png");
	private Texture2D mid_c = ResourceLoader.Load<Texture2D>("res://mid_c.png");
	private Texture2D top_c = ResourceLoader.Load<Texture2D>("res://top_c.png");
	private Texture2D bot_d = ResourceLoader.Load<Texture2D>("res://bot_d.png");
	private Texture2D mid_d = ResourceLoader.Load<Texture2D>("res://mid_d.png");
	private Texture2D top_d = ResourceLoader.Load<Texture2D>("res://top_d.png");
	private Texture2D bot_e = ResourceLoader.Load<Texture2D>("res://bot_e.png");
	private Texture2D mid_e = ResourceLoader.Load<Texture2D>("res://mid_e.png");
	private Texture2D top_e = ResourceLoader.Load<Texture2D>("res://top_e.png");

	private MeshInstance3D l1;
	private MeshInstance3D l2;
	private MeshInstance3D l3;
	private Node3D my_root;
	private CollisionShape3D collision;
	private Dictionary<string, Area3D> _occluders = new Dictionary<string, Area3D>();
	private Vector2[] _centers;

	public override void _Ready()
	{
		l1 = GetNode<MeshInstance3D>("leaves_1");
		l2 = GetNode<MeshInstance3D>("leaves_2");
		l3 = GetNode<MeshInstance3D>("leaves_3");
		my_root = GetParent<Node3D>().GetParent<NavigationRegion3D>().GetParent<Node3D>();
		collision = GetNode<CollisionShape3D>("Area3D/CollisionShape3D");

		set_graphics("original");

		l1.MaterialOverride = (ShaderMaterial)(l1.MaterialOverride.Duplicate());
		l2.MaterialOverride = (ShaderMaterial)(l2.MaterialOverride.Duplicate());
		l3.MaterialOverride = (ShaderMaterial)(l3.MaterialOverride.Duplicate());
		set_low_lod();

		ShaderMaterial l1m = (ShaderMaterial)l1.MaterialOverride;
		ShaderMaterial l2m = (ShaderMaterial)l2.MaterialOverride;
		ShaderMaterial l3m = (ShaderMaterial)l3.MaterialOverride;

		l1m.SetShaderParameter("rotation", 90 - Rotation.Y);
		l2m.SetShaderParameter("rotation", 90 - Rotation.Y);
		l3m.SetShaderParameter("rotation", 90 - Rotation.Y);

		float to = 0.1f + GD.Randf() * (1.9f - 0.1f);
		l1m.SetShaderParameter("time_offset", to);
		l2m.SetShaderParameter("time_offset", to);
		l3m.SetShaderParameter("time_offset", to);

		AddToGroup("trees");
	}

	public override void _Process(double delta)
	{
		_centers = new Vector2[_occluders.Count];
		int idx = 0;
		foreach (KeyValuePair<string, Area3D> entry in _occluders)
    {
			Vector3 gp = GlobalPosition - entry.Value.GlobalPosition;
			Vector3 s = ((BoxShape3D)collision.Shape).Size;
			Vector2 gp2 = new Vector2(
				normalize(gp.X, s.X * 0.5f, -s.X * 0.5f),
				normalize(gp.Z, s.Z * 0.5f, -s.Z * 0.5f)
			);
			gp2 = rotate_around_center(gp2, new Vector2(0.5f, 0.5f), Rotation.Y);
			_centers[idx++] = gp2;
			// my_root.occluders += 1;
		}
		ShaderMaterial l1m = (ShaderMaterial)l1.MaterialOverride;
		ShaderMaterial l2m = (ShaderMaterial)l2.MaterialOverride;
		ShaderMaterial l3m = (ShaderMaterial)l3.MaterialOverride;
		l1m.SetShaderParameter("vignette_centers", _centers);
		l2m.SetShaderParameter("vignette_centers", _centers);
		l3m.SetShaderParameter("vignette_centers", _centers);
	}

	private float normalize(float value, float min_original, float max_original) 
	{
		return (value - min_original) / (max_original - min_original);
	}

	private Vector2 rotate_around_center(Vector2 point, Vector2 center, float angle)
  {
		float s = (float)Math.Sin(angle);
		float c = (float)Math.Cos(angle);
		point -= center;
		float xnew = point.X * c - point.Y * s;
		float ynew = point.X * s - point.Y * c;
		point.X = xnew;
		point.Y = ynew;
		return point;
	}

	public void _on_area_3d_area_entered(Area3D area)
	{
		_occluders.Add(area.Name, area);
	}

	public void _on_area_3d_area_exited(Area3D area)
	{
		_occluders.Remove(area.Name);
	}

	private void set_wind_rot(float rads)
  {
		ShaderMaterial l1m = (ShaderMaterial)l1.MaterialOverride;
		ShaderMaterial l2m = (ShaderMaterial)l2.MaterialOverride;
		ShaderMaterial l3m = (ShaderMaterial)l3.MaterialOverride;
		l1m.SetShaderParameter("rotation", rads - Rotation.Y);
		l2m.SetShaderParameter("rotation", rads - Rotation.Y);
		l3m.SetShaderParameter("rotation", rads - Rotation.Y);
	}

	private float remap(float value, float old_min, float old_max, float new_min, float new_max) 
	{
		return new_min + ((value - old_min) / (old_max - old_min)) * (new_max - new_min);
	}

	private void set_wind_strength(float value, float min, float max)
	{
		ShaderMaterial l1m = (ShaderMaterial)l1.MaterialOverride;
		ShaderMaterial l2m = (ShaderMaterial)l2.MaterialOverride;
		ShaderMaterial l3m = (ShaderMaterial)l3.MaterialOverride;

		l1m.SetShaderParameter("time_factor", value);
		l2m.SetShaderParameter("time_factor", value);
		l3m.SetShaderParameter("time_factor", value);

		l1m.SetShaderParameter(
			"sway_frequency", remap(value, min, max, 0.1f, 3f));
		l2m.SetShaderParameter(
			"sway_frequency", remap(value, min, max, 0.1f, 3f));
		l3m.SetShaderParameter(
			"sway_frequency", remap(value, min, max, 0.1f, 3f));

		l1m.SetShaderParameter(
			"sway_amplitude", remap(value, min, max, 0.01f, 0.06f));
		l2m.SetShaderParameter(
			"sway_amplitude", remap(value, min, max, 0.03f, 0.10f));
		l3m.SetShaderParameter(
			"sway_amplitude", remap(value, min, max, 0.05f, 0.15f));
	}

	private void set_low_lod()
	{
		l2.Transparency = 0.0f;
		l3.Transparency = 0.0f;
		GetNode<MeshInstance3D>("dirt").Transparency = 0.0f;
		l1.CastShadow = GeometryInstance3D.ShadowCastingSetting.Off;
		l2.CastShadow = GeometryInstance3D.ShadowCastingSetting.Off;
		l3.CastShadow = GeometryInstance3D.ShadowCastingSetting.Off;
		Tween tween_1 = GetTree().CreateTween();
		tween_1.TweenProperty(l2, "transparency", 1.0, 0.2f);
		Tween tween_2 = GetTree().CreateTween();
		tween_2.TweenProperty(l3, "transparency", 1.0, 0.2f);
		Tween tween_3 = GetTree().CreateTween();
		tween_3.TweenProperty(GetNode<MeshInstance3D>("dirt"), "transparency", 1.0, 0.2);
	}

	private void set_high_lod()
	{
		l2.Transparency = 1.0f;
		l3.Transparency = 1.0f;
		GetNode<MeshInstance3D>("dirt").Transparency = 1.0f;
		l2.Visible = true;
		l3.Visible = true;
		GetNode<MeshInstance3D>("dirt").Visible = false;
		l2.CastShadow = GeometryInstance3D.ShadowCastingSetting.Off;
		l3.CastShadow = GeometryInstance3D.ShadowCastingSetting.Off;
		Tween tween_1 = GetTree().CreateTween();
		tween_1.TweenProperty(l2, "transparency", 0.0, 0.2f);
		Tween tween_2 = GetTree().CreateTween();
		tween_2.TweenProperty(l3, "transparency", 0.0, 0.2f);
		Tween tween_3 = GetTree().CreateTween();
		tween_3.TweenProperty(GetNode<MeshInstance3D>("dirt"), "transparency", 0.0, 0.2);
		tween_3.TweenCallback(Callable.From(set_shadow_on));
	}

	private void set_invisible()
  {
		l1.Visible = false;
		l2.Visible = false;
		GetNode<MeshInstance3D>("dirt").Visible = false;
	}

	private void set_shadow_on()
	{
		l1.CastShadow = GeometryInstance3D.ShadowCastingSetting.On;
		l2.CastShadow = GeometryInstance3D.ShadowCastingSetting.On;
		l3.CastShadow = GeometryInstance3D.ShadowCastingSetting.On;
	}

	private void set_graphics(String option)
	{
		ShaderMaterial l1m = (ShaderMaterial)l1.MaterialOverride;
		ShaderMaterial l2m = (ShaderMaterial)l2.MaterialOverride;
		ShaderMaterial l3m = (ShaderMaterial)l3.MaterialOverride;
		switch (option)
		{
			case "original":
				l1m.SetShaderParameter("image_texture", bot_a);
				l2m.SetShaderParameter("image_texture", mid_a);
				l3m.SetShaderParameter("image_texture", top_a);
				break;
			case "speed_tree":
				l1m.SetShaderParameter("image_texture", bot_b);
				l2m.SetShaderParameter("image_texture", mid_b);
				l3m.SetShaderParameter("image_texture", top_b);
				break;
			case "speed_tree_expanded":
				l1m.SetShaderParameter("image_texture", bot_c);
				l2m.SetShaderParameter("image_texture", mid_c);
				l3m.SetShaderParameter("image_texture", top_c);
				break;
			case "speed_tree_grayscale":
				l1m.SetShaderParameter("image_texture", bot_d);
				l2m.SetShaderParameter("image_texture", mid_d);
				l3m.SetShaderParameter("image_texture", top_d);
				break;
			case "speed_tree_greenscale":
				l1m.SetShaderParameter("image_texture", bot_e);
				l2m.SetShaderParameter("image_texture", mid_e);
				l3m.SetShaderParameter("image_texture", top_e);
				break;
		}
	}
}