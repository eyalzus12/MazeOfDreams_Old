using Godot;
using GodotOnReady.Attributes;
using System;

public partial class Hitbox : Area2D
{
    [Export]
    public float Damage{get; set;}
    [Export]
    public float StunTime{get; set;}
    [Export]
    public float Pushback{get; set;}

    [OnReadyGet(nameof(HitboxShape))]
    public CollisionShape2D HitboxShape{get; set;}

    public virtual void Disable() => HitboxShape.SetDeferred("disabled",true);
    public virtual void Enable() => HitboxShape.SetDeferred("disabled",false);
}
