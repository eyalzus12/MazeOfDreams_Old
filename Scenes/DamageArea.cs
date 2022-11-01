using Godot;
using System;

public class DamageArea : Area2D
{
    public override void _Ready()
    {
        Connect("body_entered", this, nameof(OnBodyEnter));
    }

    public void OnBodyEnter(Node n)
    {
        if(n is DamageableCharacter dc) dc.Health--;
    }
}
