using Godot;
using System;
using GodotOnReady.Attributes;

public partial class Sword : Node2D
{
    [OnReadyGet(nameof(SwordAnimationPlayer))]
    public AnimationPlayer SwordAnimationPlayer{get; set;}

    [OnReadyGet(nameof(SwordHitbox))]
    public Hitbox SwordHitbox{get; set;}

    [OnReady]
    public void DisableHitbox() => SwordHitbox.Disable();
    public void EnableHitbox() => SwordHitbox.Enable();

    public virtual void Attack()
    {
        SwordAnimationPlayer.Play("SwordAttack");
    }

    public virtual void OnAttackEnd(string animationName)
    {
        if(animationName == "RESET") return;
        SwordAnimationPlayer.Play("RESET");
        SwordAnimationPlayer.Advance(0);
        SwordAnimationPlayer.Stop(true);
    }
}
