using System;
using Godot;

public partial class Randomizer : Node
{
    public Randomizer() {}

    public RandomNumberGenerator RNG{get; private set;} = new RandomNumberGenerator();

    public ulong InitialSeed{get; private set;}
    public ulong State{get => RNG.State; set => RNG.State = value;}

    public override void _Ready()
    {
        RNG.Randomize();
        SetInitialSeed(RNG.Seed);
        GD.Print($"Initial random seed is {InitialSeed}");
    }

    public void SetInitialSeed(ulong seed)
    {
        InitialSeed = seed;
        RNG.Seed = InitialSeed;
    }

    public void SetInitialSeed(string seed)
    {
        ulong numseed;
        if(!ulong.TryParse(seed, out numseed)) numseed = Convert.ToUInt64((uint)GD.Hash(seed));
        SetInitialSeed(numseed);
    }
}