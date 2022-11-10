using System;
using Godot;

public class Randomizer : Node
{
    public Randomizer() {}

    public RandomNumberGenerator RNG{get; set;} = new RandomNumberGenerator();

    public override void _Ready()
    {
        RNG.Randomize();
    }

    public void SetSeed(ulong seed)
    {
        RNG.Seed = Convert.ToUInt64(seed.GetHashCode());
    }
}