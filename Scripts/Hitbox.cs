using Godot;
using System;

public class Hitbox : Area2D
{
    [Export]
    public float Damage{get; set;}
    [Export]
    public float StunTime{get; set;}
}
