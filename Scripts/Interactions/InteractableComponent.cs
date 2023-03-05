using Godot;
using System;
using System.Collections.Generic;

public partial class InteractableComponent : Area2D
{
    [Signal]
    public delegate void InteractedEventHandler(InteractableComponent interactable, InteracterComponent interacter);

    public HashSet<InteracterComponent> interacters{get; set;} = new HashSet<InteracterComponent>();

    public InteractableComponent() {}

    [Export]
    public int InteractionPriority{get; set;} = 0;

    public override void _PhysicsProcess(double delta)
    {
        foreach(var i in interacters)
        {
            i.CurrentInteractable = this;
        }
    }

    public void OnAreaEntered(Area2D area)
    {
        if(area is InteracterComponent i)
        {
            i.CurrentInteractable = this;
            interacters.Add(i);
        }
    }

    public void OnAreaExited(Area2D area)
    {
        if(area is InteracterComponent i)
        {
            i.CurrentInteractable = null;
            interacters.Remove(i);
        }
    }

    public void OnInteract(InteracterComponent i)
    {
        EmitSignal(nameof(Interacted), this, i);
    }
}
