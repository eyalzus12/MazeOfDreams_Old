using System;
using Godot;

public class Randomizer : Node
{
    public Randomizer() {}

    public RandomNumberGenerator RNG{get; private set;} = new RandomNumberGenerator();

    public ulong Seed{get => RNG.Seed; set
    {
        RNG.Seed = value;
        GD.Print($"New random seed is {value}");
    }}

    private ulong _initialSeed;
    public ulong InitialSeed => _initialSeed;
    public object GenericInitialSeed{get => _initialSeed; set => _initialSeed = Convert.ToUInt64(GD.Hash(value));}

    public override void _Ready()
    {
        RNG.Randomize();
        _initialSeed = RNG.Seed;
        GD.Print($"Initial random seed is {_initialSeed}");
    }
}