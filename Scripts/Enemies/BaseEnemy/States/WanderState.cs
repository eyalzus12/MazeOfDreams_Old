using Godot;
using System;

public class WanderState : State<Enemy>
{
    public Timer WaitTimer{get; set;}
    public bool Waiting{get; set;}

    public override void _Ready()
    {
        WaitTimer = GetNode<Timer>(nameof(WaitTimer));
    }

    public void WaitEnded()
    {
        Waiting = false;
        var wanderPosition = Entity.GlobalPosition+Entity.RNG.GetRandomPointInCircle(Entity.MaximumWanderRadius, Entity.MinimumWanderRadius);
        Entity.TargetPosition = wanderPosition;
        
        WaitTimer.Stop();
    }

    public void WaitStarted()
    {
        Waiting = true;
        Entity.PathfindingTimer.Stop();
        var waitTime = Entity.RNG.RandfRange(Entity.MinimumWanderWaitTime, Entity.MaximumWanderWaitTime);
        WaitTimer.Start(waitTime);
    }

    public override void OnStart()
    {
        WaitStarted();
        Entity.PathfindingTimer.Stop();
    }

    public override void Loop(float delta)
    {
        if(!Waiting)
        {
            if(Entity.Pathfinding.NavAgent.IsNavigationFinished())
            {
                WaitStarted();
            }
            else
            {
                var dir = Entity.GlobalPosition.DirectionTo(Entity.NextPosition);
                Entity.Velocity = Entity.Velocity.MoveToward(dir*Entity.WanderSpeed, Entity.WanderAcceleration);
            }
        }
        else
        {
            Entity.Velocity = Entity.Velocity.MoveToward(Vector2.Zero, Entity.WanderAcceleration);
        }

        Entity.MoveAndSlide(Entity.Velocity,Vector2.Zero);
    }

    public override string NextState()
    {
        if(Entity.ChaseTarget != null)
        {
            WaitTimer.Stop();
            return "Chase";
        }

        return "";
    }

    public override void OnChange(State<Enemy> s)
    {
        Waiting = true;//to prevent starting to wait
        WaitTimer.Stop();
    }
}
