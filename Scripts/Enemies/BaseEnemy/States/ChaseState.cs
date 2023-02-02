using Godot;
using System;

public class ChaseState : State<Enemy>
{
    //public const int FINISH_THRESHOLD = 1;

    public ChaseState():base() {}

    //public int FinishCounter{get; set;}

    public override void OnStart()
    {
        //FinishCounter = 0;
        Entity.PathfindingTimer.Start();
        SetTarget();
    }

    public override void Ready()
    {
        Entity.Connect(nameof(Enemy.PathfindingUpdate),this,nameof(PathfindingUpdate));
    }

    public override void Loop(float delta)
    {
        var dir = Entity.GlobalPosition.IsEqualApprox(Entity.NextPosition)?Vector2.Zero:Entity.GlobalPosition.DirectionTo(Entity.NextPosition);
        Entity.Velocity += ((dir*Entity.ChaseSpeed)-Entity.Velocity)*Entity.ChaseAcceleration;
        Entity.MoveAndSlide(Entity.Velocity,Vector2.Zero);
    }

    public virtual void SetTarget(Vector2 offset = default)
    {
        if(Entity.ChaseTarget is null) return;
        Entity.TargetPosition = Entity.ChaseTarget.GlobalPosition + offset;
    }

    public override string NextState()
    {
        if(Entity.ChaseTarget is null && (Entity.Pathfinding.NavAgent.IsNavigationFinished() || !Entity.Pathfinding.NavAgent.IsTargetReachable())) return "Wander";
        return "";
    }

    public void PathfindingUpdate()
    {
        SetTarget();
    }

    public override void OnChange(State<Enemy> s)
    {
        Entity.PathfindingTimer.Stop();
    }
}
