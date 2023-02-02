using Godot;
using System;

public class Enemy : KinematicBody2D
{
    [Signal]
    public delegate void PathfindingUpdate();

    public const string START_STATE = "Wander";

    [Export(hintString: "WARNING: this value is used differently from other acceleration")]
    public float ChaseAcceleration = 0.1f;
    [Export]
    public float ChaseSpeed = 400f;

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
    
    public Timer PathfindingTimer{get; set;}
    public EnemyStateMachine States{get; set;}
    public RandomNumberGenerator RNG{get; set;}
    public EnemyPathfindingComponent Pathfinding{get; private set;}
    public Vector2 Velocity{get; set;} = Vector2.Zero;
    public Area2D ChaseRange{get; set;}
    public Character ChaseTarget{get; set;}

    public Vector2 NextPosition => Pathfinding.NavAgent.GetNextLocation();
    public Vector2 TargetPosition{get => Pathfinding.NavAgent.GetTargetLocation(); set => Pathfinding.NavAgent.SetTargetLocation(value);}

    public override void _Ready()
    {
        //get the RNG
        RNG = GetTree().Root.GetNodeOrNull<Randomizer>(nameof(Randomizer))?.RNG;
        if(RNG is null)
        {
            GD.PushError($"Enemy {Name} cannot properly work as the RNG is non-existent or null");
            return;
        }

        Pathfinding = GetNode<EnemyPathfindingComponent>(nameof(EnemyPathfindingComponent));

        PathfindingTimer = GetNode<Timer>(nameof(PathfindingTimer));

        ChaseRange = GetNode<Area2D>(nameof(ChaseRange));

        States = GetNodeOrNull<EnemyStateMachine>(nameof(States));
		if(States != null)
		{
			States.StoreStates();
			States.Entity = this;
			States.UpdateStateEntities();
			States.CurrentState = States.States[START_STATE];
		}
    }

    public override void _PhysicsProcess(float delta)
    {
        //update states
		if(States != null)
		{
			States.StateUpdate(delta);
		}
    }

    public void UpdatePathing()
    {
        EmitSignal(nameof(PathfindingUpdate));
    }

    public virtual void OnChaseRangeEntered(Node body)
    {
        if(body is Character c) ChaseTarget = c;
    }

    public virtual void OnChaseRangeExited(Node body)
    {
        if(body == ChaseTarget) ChaseTarget = null;
    }
}
