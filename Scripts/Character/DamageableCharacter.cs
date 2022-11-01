using Godot;
using System;
using System.Threading;
using System.Threading.Tasks;

public class DamageableCharacter : Character, IDamageable
{
    public float Health { get; set; } = 100;
    public Label DamageLabel { get; set; }

    public void UpdateHealthBar()
    {
        DamageLabel.Text = Health.ToString();
    }

    public override void _Ready()
    {
        base._Ready();
        DamageLabel = GetNode<Label>("UILayer/DamageLabel");
    }

    public override void _PhysicsProcess(float delta)
    {
        base._PhysicsProcess(delta);
        UpdateHealthBar();
    }

}
