using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public class RoomSpreader : Node2D
{
    [Signal]
    public delegate void SpreadingFinished(List<Vector2> positions);

    public int TileSize{get; set;} = 1;
    public int SpawnRadius{get; set;} = 50;
    private List<RID> _bodies = new List<RID>();
    public List<Shape2D> Shapes{get; set;}
    public RandomNumberGenerator RNG{get; private set;}

    private int _engineIterations;

    public RoomSpreader() {}
    public RoomSpreader(int tileSize, int spawnRadius, IEnumerable<Shape2D> shapes)
    {
        Shapes = shapes.ToList();
        TileSize = tileSize;
        SpawnRadius = spawnRadius;
    }

    public override void _Ready()
    {
        //save physics speed for later
        _engineIterations = Engine.IterationsPerSecond;

        //increase physics speed
        Engine.IterationsPerSecond = 240;

        //get RNG
        RNG = GetTree().Root.GetNode<Randomizer>(nameof(Randomizer)).RNG;

        for(int i = 0; i < Shapes.Count; ++i)
        {
            //create a body
            var body = Physics2DServer.BodyCreate();
            //set it to be rigid, and not rotate
            Physics2DServer.BodySetMode(body, Physics2DServer.BodyMode.Character);
            //put inside the space
            Physics2DServer.BodySetSpace(body, GetWorld2d().Space);
            //set it to a random position
            var position = RNG.GetRandomPointInCircle(SpawnRadius).Snapped(TileSize*Vector2.One);
            Physics2DServer.BodySetState(body, Physics2DServer.BodyState.Transform, new Transform2D(0f, position));
            //remove gravity
            Physics2DServer.BodySetParam(body, Physics2DServer.BodyParameter.GravityScale, 0f);
            //set its shape
            var shape = Shapes[i];
            shape.CustomSolverBias = 1f;
            Physics2DServer.BodyAddShape(body, shape.GetRid());
            
            //add to the list
            _bodies.Add(body);
        }

        //make sure physics happen
        Physics2DServer.SetActive(true);
        
        //in 2 seconds, gather positions
        //FIX: this runs in the normal process instead of the physics one
        GetTree().CreateTimer(2).Connect("timeout", this, nameof(OnTimeout));
    }

    public void OnTimeout()
    {
        //restore physics speed
        Engine.IterationsPerSecond = _engineIterations;
        //get the resulting positions
        var result = _bodies.Select(b => ((Transform2D)Physics2DServer.BodyGetState(b, Physics2DServer.BodyState.Transform)).origin.Snapped(TileSize*Vector2.One)).ToList();
        //dispose of the bodies
        for(int i = 0; i < _bodies.Count; ++i) Physics2DServer.FreeRid(_bodies[i]);
        //return result
        EmitSignal(nameof(SpreadingFinished), result);
    }
}
