using Godot;
using System;

public class EnemyPathfindingComponent : Node2D
{
    [Signal]
    public delegate void NextPosition(Vector2 next);

    public NavigationAgent2D NavAgent{get; private set;}

    public override void _Ready()
    {
        NavAgent = GetNodeOrNull<NavigationAgent2D>(nameof(NavAgent));
    }

    public void OnPathing(Vector2 target)
    {
        NavAgent.SetTargetLocation(target);
    }

    public override void _PhysicsProcess(float delta)
    {
        if(NavAgent.IsNavigationFinished()) return;
        EmitSignal(nameof(NextPosition), NavAgent.GetNextLocation());
    }
}
