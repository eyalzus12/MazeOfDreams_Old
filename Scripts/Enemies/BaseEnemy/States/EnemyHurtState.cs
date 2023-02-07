using Godot;
using System;

public class EnemyHurtState : State<Enemy>
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
        Entity.Velocity = Entity.Velocity.MoveToward(Vector2.Zero, Entity.StunFriction);
    }

    public override void OnStart()
    {
        Entity.EnemyAnimationPlayer.Play("Hurt");
        Stunned = true;
        Entity.EnemyHurtbox.Disable();
        Entity.InvincibilityTimer.Start(Entity.InvincibilityPeriod);
        StunTimer.Start(Entity.StunTime);
    }

    public override string NextState() => Stunned?"":"Wander";

    public virtual void OnStunEnd()
    {
        Stunned = false;
        Entity.EnemyAnimationPlayer.Play("RESET");
        Entity.EnemyAnimationPlayer.Advance(0);
        Entity.EnemyAnimationPlayer.Stop(true);
    }
}
