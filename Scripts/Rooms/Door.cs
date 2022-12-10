using System;
using Godot;

public class Door : StaticBody2D
{
    [Signal]
    public delegate void Interacted(Door door, InteracterComponent interacter);

    [Export(PropertyHint.Enum)]
    public DoorDirection Direction{get; set;}

    [Export]
    public bool InitiallyOpen{get; set;} = false;

    public InteractableComponent Interactable{get; set;}
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
            DoorCollision?.SetDeferred("disabled", value);
            Interactable?.SetDeferred("monitoring", !value);
            if(DoorOpenSprite != null) DoorOpenSprite.Visible = value;
            if(DoorClosedSprite != null) DoorClosedSprite.Visible = !value;
        }
    }

    public override void _Ready()
    {
        Interactable = GetNodeOrNull<InteractableComponent>(nameof(InteractableComponent));
        DoorCollision = GetNodeOrNull<CollisionShape2D>(nameof(DoorCollision));
        DoorOpenSprite = GetNodeOrNull<Sprite>(nameof(DoorOpenSprite));
        DoorClosedSprite = GetNodeOrNull<Sprite>(nameof(DoorClosedSprite));
        Open = InitiallyOpen;
    }

    public void OnInteracted(InteractableComponent interactable, InteracterComponent interacter)
    {
        EmitSignal(nameof(Interacted), this, interacter);
    }

    public enum DoorDirection
    {
        North,
        South,
        East,
        West
    }
}