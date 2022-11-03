using System;
using System.Collections.Generic;
using System.Linq;
using Godot;

public class GameRoom : Node2D
{
    public Dictionary<Door.DoorDirection, List<Door>> DoorsDict{get; set;} = new Dictionary<Door.DoorDirection, List<Door>>();
    public List<Door> Doors{get; set;} = new List<Door>();

    public GameRoom() {}

    public override void _Ready()
    {
        InitDoors();
    }

    public virtual void InitDoors()
    {
        //get door list
        Doors = GetChildren().OfType<Door>().ToList();
        //split into groups by direction
        DoorsDict = Doors.GroupBy(d => d.Direction).ToDictionary(k=>k.Key, e=>e.ToList());
        //connect interaction signal to function
        foreach(var door in Doors) door.Connect(nameof(Door.Interacted), this, nameof(OnDoorInteract));
    }

    public virtual void OnDoorInteract(Door who)
    {
        GD.Print(who.Direction);
    }
}