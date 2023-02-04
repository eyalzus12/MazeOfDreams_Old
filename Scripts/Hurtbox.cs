using Godot;
using System;

public class Hurtbox : Area2D
{
    public CollisionShape2D HurtboxShape{get; set;}

    public override void _Ready()
    {
        HurtboxShape = GetNodeOrNull<CollisionShape2D>(nameof(HurtboxShape));
    }

    public virtual void Disable()
    {
        if(HurtboxShape != null) HurtboxShape.SetDeferred("disabled",true);
    }
    
    public virtual void Enable()
    {
        if(HurtboxShape != null) HurtboxShape.SetDeferred("disabled",false);
    }
}
