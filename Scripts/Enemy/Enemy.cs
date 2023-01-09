using Godot;
using System;

public class Enemy : KinematicBody2D
{
    public EnemyPathfindingComponent Pathfinding{get; private set;}
    public Vector2 Velocity{get; set;} = Vector2.Zero;
    public Node2D Followed{get; set;}

    [Export]
    public float Acceleration = 10f;
    [Export]
    public float Speed = 100f;

    public override void _Ready()
    {
        Pathfinding = GetNode<EnemyPathfindingComponent>(nameof(EnemyPathfindingComponent));
        Pathfinding.Connect(nameof(EnemyPathfindingComponent.NextPosition), this, nameof(OnNextPosition));
        Followed = (Node2D)GetTree().GetNodesInGroup("character")[0];
    }

    public void OnNextPosition(Vector2 next)
    {
        var direction = GlobalPosition.DirectionTo(next);
        Velocity = Velocity.MoveToward(direction*Speed, Acceleration);
        MoveAndSlide(Velocity);
    }

    public override void _PhysicsProcess(float delta)
    {
        
    }

    public virtual void UpdatePathing()
    {
        Pathfinding.OnPathing(Followed.GlobalPosition);
    }
}
