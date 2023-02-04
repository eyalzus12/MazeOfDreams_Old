using Godot;
using System;

public class HurtState : State<Character>
{
    public bool Stunned{get; set;}
    public Timer StunTimer{get; set;}

    public override void _Ready()
    {
        StunTimer = GetNode<Timer>(nameof(StunTimer));
    }

    public override void Loop(float delta)
    {
        Entity.MoveAndSlide(Entity.Velocity,Vector2.Zero);
        Entity.Velocity = Entity.Velocity.MoveToward(Vector2.Zero, 10f);
    }

    public override void OnStart()
    {
        Entity.CharacterAnimationPlayer.Play("Hurt");
        Stunned = true;
        Entity.CharacterHurtbox.Disable();
        Entity.InvincibilityTimer.Start(Entity.InvincibilityPeriod);
        StunTimer.Start(Entity.StunTime);
    }

    public override string NextState() => Stunned?"":"Base";

    public virtual void OnStunEnd()
    {
        Stunned = false;
        Entity.CharacterAnimationPlayer.Play("RESET");
        Entity.CharacterAnimationPlayer.Advance(0);
        Entity.CharacterAnimationPlayer.Play("Invincibility");
    }
}
