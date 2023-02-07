using Godot;
using System;
using GodotOnReady.Attributes;

public partial class Enemy : KinematicBody2D
{
    [Signal]
    public delegate void PathfindingUpdate();

    public const string START_STATE = "Wander";

    [Export(hintString: "WARNING: this value is used differently from other acceleration")]
    public float ChaseAcceleration = 0.1f;
    [Export]
    public float ChaseSpeed = 280f;

    [Export]
    public float MaximumWanderRadius{get; set;} = 60f;
    [Export]
    public float MinimumWanderRadius{get; set;} = 40f;
    [Export]
    public float WanderSpeed{get; set;} = 50f;
    [Export]
    public float WanderAcceleration{get; set;} = 10f;
    [Export]
    public float MinimumWanderWaitTime{get; set;} = 2f;
    [Export]
    public float MaximumWanderWaitTime{get; set;} = 4f;
    [Export]
    public float StunFriction{get; set;} = 10f;
    
    [OnReadyGet(nameof(PathfindingTimer))]
    public Timer PathfindingTimer{get; set;}
    [OnReadyGet(nameof(States))]
    public EnemyStateMachine States{get; set;}
    public RandomNumberGenerator RNG{get; set;}

    [OnReadyGet(nameof(EnemyPathfindingComponent))]
    public EnemyPathfindingComponent Pathfinding{get; private set;}

    public Vector2 Velocity{get; set;} = Vector2.Zero;

    [OnReadyGet(nameof(ChaseRange))]
    public Area2D ChaseRange{get; set;}
    public Node2D ChaseTarget{get; set;}

    [OnReadyGet(nameof(EnemyHitbox))]
    public Hitbox EnemyHitbox{get; set;}

    [OnReadyGet(nameof(EnemyHurtbox))]
    public Hurtbox EnemyHurtbox{get; set;}

    [OnReadyGet(nameof(EnemyAnimationPlayer))]
    public AnimationPlayer EnemyAnimationPlayer{get; set;}
    [OnReadyGet(nameof(InvincibilityTimer))]
	public Timer InvincibilityTimer{get; set;}

    public Vector2 NextPosition => Pathfinding.NavAgent.GetNextLocation();
    public Vector2 TargetPosition{get => Pathfinding.NavAgent.GetTargetLocation(); set => Pathfinding.NavAgent.SetTargetLocation(value);}

    [Export]
	public float InitialHP = 100f;

	public float CurrentHP{get; set;}
    public float StunTime{get; set;}

	[Export]
	public float InvincibilityPeriod = 0.5f;

    [OnReady]
    public virtual void Setup()
    {
        CurrentHP = InitialHP;

        //get the RNG
        RNG = GetTree().Root.GetNodeOrNull<Randomizer>(nameof(Randomizer))?.RNG;
        if(RNG is null)
        {
            GD.PushError($"Enemy {Name} cannot properly work as the RNG is non-existent or null");
            return;
        }

        States.StoreStates();
        States.Entity = this;
        States.UpdateStateEntities();
        States.CurrentState = States.States[START_STATE];
    }

    public override void _PhysicsProcess(float delta)
    {
        States?.StateUpdate(delta);
    }

    public void UpdatePathing()
    {
        EmitSignal(nameof(PathfindingUpdate));
    }

    public virtual void OnChaseRangeEntered(Node body)
    {
        if(body is Node2D n) ChaseTarget = n;
    }

    public virtual void OnChaseRangeExited(Node body)
    {
        if(body == ChaseTarget) ChaseTarget = null;
    }

    public virtual void OnHit(Area2D area)
    {
        Velocity *= 0.5f;
    }

    public virtual void OnGotHit(Area2D area)
	{
		if(area is Hitbox hitbox)
		{
			CurrentHP -= hitbox.Damage;
			StunTime = hitbox.StunTime;
			States.SetState("Hurt");
			Velocity += (area.GlobalPosition.DirectionTo(GlobalPosition))*hitbox.Pushback;
		}
	}

	public virtual void OnInvincibilityEnd()
	{
		EnemyHurtbox.Enable();
		EnemyAnimationPlayer.Play("RESET");
        EnemyAnimationPlayer.Advance(0);
		EnemyAnimationPlayer.Stop(true);
	}
}
