using Godot;
using System;

public class GameFloor : Node2D
{
    private MazeDreamer _dreamer;

    public GameFloor() {}

    public override void _Ready()
    {
        _dreamer = GetNodeOrNull<MazeDreamer>(nameof(MazeDreamer));
        _dreamer.Connect(nameof(MazeDreamer.DreamingFinished), this, nameof(OnDreamingFinished));
    }

    public void OnDreamingFinished(GameRoom spawn)
    {
        //var character = GetNodeOrNull<Character>(nameof(Character));
        //character.GlobalPosition = spawn.GlobalPosition;
        //var enemy = GetNodeOrNull<Enemy>(nameof(Enemy));
        //enemy.GlobalPosition = spawn.GlobalPosition;
    }
}
