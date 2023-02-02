using Godot;
using System;

public class TestFlyingChargingEnemy : Enemy
{
    [Export]
    public float ChargeCooldown;
    [Export]
    public float ChargeSpeed;
    [Export]
    public float ChargeAcceleration;
    [Export]
    public float ChargeLength;


    public Area2D ChargeRange{get; set;}
    public Timer ChargeTimer{get; set;}

    public override void _Ready()
    {
        base._Ready();
    }
}
