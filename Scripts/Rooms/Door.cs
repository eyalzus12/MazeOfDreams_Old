using System;
using System.Collections.Generic;
using System.Linq;
using Godot;

public class Door : StaticBody2D, IInteractable
{
    [Signal]
    public delegate void Interacted(Door who);

    [Export(PropertyHint.Enum)]
    public DoorDirection Direction{get; set;}

    [Export]
    public int InteractionPriority{get; set;}

    [Export]
    public bool InitiallyOpen{get; set;} = false;

    public Area2D InteractionArea{get; set;}
    public CollisionShape2D DoorCollision{get; set;}
    public Sprite DoorOpenSprite{get; set;}
    public Sprite DoorClosedSprite{get; set;}


    private bool _open;
    public bool Open
    {
        get => _open;
        set
        {
            _open = value;
            DoorCollision.SetDeferred("disabled", value);
            DoorOpenSprite.Visible = value;
            DoorClosedSprite.Visible = !value;
        }
    }

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
        InteractionArea = GetNodeOrNull<Area2D>("InteractionArea");
        if(InteractionArea is null)
        {
            GD.PushError($"Door {Name} has no interaction area (If it does, make sure you named it InteractionArea).");
        }
        else
        {
            InteractionArea.Connect("body_entered", this, nameof(OnAreaBodyEnter));
            InteractionArea.Connect("body_exited", this, nameof(OnAreaBodyExit));
        }

        
        DoorCollision = GetNodeOrNull<CollisionShape2D>("DoorCollision");
        if(DoorCollision is null) GD.PushError($"Door {Name} has no collision shape (If it does, make sure you named it DoorCollision).");

        DoorOpenSprite = GetNodeOrNull<Sprite>("DoorOpenSprite");
        if(DoorOpenSprite is null) GD.PushError($"Door {Name} ");
        
        DoorClosedSprite = GetNodeOrNull<Sprite>("DoorClosedSprite");
        if(DoorClosedSprite is null) GD.PushError($"Door {Name} has no closed sprite (If it does, make sure you named it DoorClosedSprite).");

        Open = InitiallyOpen;
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