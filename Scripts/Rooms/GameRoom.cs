using System;
using System.Collections.Generic;
using System.Linq;
using Godot;

public class GameRoom : Node2D
{
    public Dictionary<Door.DoorDirection, List<Door>> DoorsDict{get; set;} = new Dictionary<Door.DoorDirection, List<Door>>();
    public List<Door> Doors{get; set;} = new List<Door>();
    public TileMap Tiles{get; set;}
    
    [Export]
    public Shape2D BoundingShape{get; set;}

    public GameRoom() {}

    public override void _Ready()
    {
        Tiles = GetNodeOrNull<TileMap>("Tiles");
        InitDoors();
    }

    public virtual void InitDoors()
    {
        //get door list
        Doors = this.GetChildren<Door>().ToList();
        //split into groups by direction
        DoorsDict = Doors.GroupByToDictionary(d => d.Direction);
        //connect interaction signal to function
        foreach(var door in Doors) door.Connect(nameof(Door.Interacted), this, nameof(OnDoorInteract));
    }

    public virtual void OnDoorInteract(Door door, InteracterComponent interacter)
    {
        door.Open = true;
    }
}