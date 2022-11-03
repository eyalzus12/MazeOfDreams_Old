using System;
using Godot;

public class Door : StaticBody2D, IInteractable
{
    [Signal]
    public delegate void Interacted(Door who);

    [Export(PropertyHint.Enum)]
    public DoorDirection Direction{get; set;}

    [Export]
    public int InteractionPriority{get; set;}

    public Area2D InteractionArea{get; set;}

    public override void _Ready()
    {
        InitInteractionArea();
    }

    public override void _PhysicsProcess(float delta)
    {
        LoopAreaCheck();
    }

    public void InitInteractionArea()
    {
        InteractionArea = GetNode<Area2D>("InteractionArea");
        InteractionArea.Connect("body_entered", this, nameof(OnAreaBodyEnter));
        InteractionArea.Connect("body_exited", this, nameof(OnAreaBodyExit));
    }

    public void OnAreaBodyEnter(Node2D n)
    {
        //if(n is IInteracter ii) ii.CurrentInteractable = this;
    }

    public void OnAreaBodyExit(Node2D n)
    {
        if(n is IInteracter ii) ii.CurrentInteractable = null;
    }

    public void LoopAreaCheck()
    {
        foreach(var b in InteractionArea.GetOverlappingBodies()) if(b is IInteracter ii)
            ii.CurrentInteractable = this;
    }

    public void OnInteract(IInteracter ii)
    {
        EmitSignal(nameof(Interacted), this);
    }

    public enum DoorDirection
    {
        North,
        South,
        East,
        West
    }
}