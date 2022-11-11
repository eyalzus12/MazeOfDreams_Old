using System;
using Godot;

public class Randomizer : Node
{
    public Randomizer() {}

    public RandomNumberGenerator RNG{get; set;} = new RandomNumberGenerator();

    private ulong _initialSeed;
    public ulong InitialSeed{get => _initialSeed; set => _initialSeed = Convert.ToUInt64(GD.Hash(value));}

    public override void _Ready()
    {
        RNG.Randomize();
        _initialSeed = RNG.Seed;
    }
}