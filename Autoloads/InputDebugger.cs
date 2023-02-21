using Godot;
using System;

public class InputDebugger : Node
{
    public bool InputDebug{get; set;} = false;

    public override void _Process(float delta)
    {
        if(Input.IsActionJustPressed("toggle_input_debug")) InputDebug = !InputDebug;
    }

    public override void _UnhandledInput(InputEvent @event)
    {
        if(@event is InputEventMouseMotion) return;
        if(InputDebug) GD.Print(@event.AsText());
    }
}
