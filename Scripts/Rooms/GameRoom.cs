using System;
using System.Collections.Generic;
using System.Linq;
using Godot;

public partial class GameRoom : Node2D
{
    public Dictionary<Door.DoorDirection, List<Door>> DoorsDict{get; set;} = new Dictionary<Door.DoorDirection, List<Door>>();
    public List<Door> Doors{get; set;} = new List<Door>();
    public TileMap Tiles{get; set;}

    public int RoomIndex{get; set;}
    public int GenerationIndex{get; set;}
    public bool GenerationUsed{get; set;}

    [Export(PropertyHint.Enum)]
    public RoomType Type{get; set;}

    [Export]
    public Godot.Collections.Array<string> BridgePassBlockers{get; set;} = new Godot.Collections.Array<string>();

    [Export]
    public Godot.Collections.Dictionary<string, string> BridgeConnectionReplacements{get; set;} = new Godot.Collections.Dictionary<string, string>();

    [Export]
    public Godot.Collections.Dictionary<string, PackedScene> BridgeConnectionScenes{get; set;} = new Godot.Collections.Dictionary<string, PackedScene>();

    [Export]
    public Godot.Collections.Dictionary<string, string> PostBridgeReplacements{get; set;} = new Godot.Collections.Dictionary<string, string>();

    [Export]
    public Godot.Collections.Array<string> DiscourgeNear{get; set;} = new Godot.Collections.Array<string>();

    public List<(Transform2D, Shape2D)> BoundShapes{get; set;}

    public GameRoom() {}

    public override void _Ready()
    {
        Tiles = GetNodeOrNull<TileMap>(nameof(Tiles));
        BoundShapes = GetNode(nameof(BoundShapes)).GetChildren().OfType<CollisionShape2D>().Select(c => (c.Transform, c.Shape)).ToList();
    }

    public virtual void InitDoors()
    {
        //get door list
        Doors = this.GetChildren<Door>().ToList();
        //split into groups by direction
        DoorsDict = Doors.GroupByToDictionary(d => d.Direction);
        //connect interaction signal to function
        foreach(var door in Doors) door.Connect(nameof(Door.Interacted),new Callable(this,nameof(OnDoorInteract)));
    }

    public virtual void OnDreamingFinished()
    {
        InitDoors();
    }

    public virtual void OnDoorInteract(Door door, InteracterComponent interacter)
    {
        door.Open = true;
    }

    public enum RoomType
    {
        Main,
        Side
    }
}