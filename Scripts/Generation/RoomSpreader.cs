using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public class RoomSpreader : Node2D
{
    const float WAIT_TIME = 2;

    [Signal]
    public delegate void SpreadingFinished(List<Vector2> positions);

    public Vector2 TileSize{get; set;} = 64*Vector2.One;
    public int SpawnRadius{get; set;} = 50;
    private List<RID> _bodies = new List<RID>();
    public List<Shape2D> Shapes{get; set;}
    public RandomNumberGenerator RNG{get; private set;}

    private int _engineIterations;
    private RID _space;

    public RoomSpreader() {}
    public RoomSpreader(Vector2 tileSize, int spawnRadius, IEnumerable<Shape2D> shapes)
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

        //create a space
        _space = Physics2DServer.SpaceCreate();
        //make the space active
        Physics2DServer.SpaceSetActive(_space, true);

        for(int i = 0; i < Shapes.Count; ++i)
        {
            //create a body
            var body = Physics2DServer.BodyCreate();
            //set it to be rigid, and not rotate
            Physics2DServer.BodySetMode(body, Physics2DServer.BodyMode.Character);
            //put inside the space
            Physics2DServer.BodySetSpace(body, _space);
            //set it to a random position
            var position = RNG.GetRandomPointInCircle(SpawnRadius);
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
        this.TimePhysicsAction(WAIT_TIME, nameof(OnTimeout));
    }

    public void OnTimeout()
    {
        //restore physics speed
        Engine.IterationsPerSecond = _engineIterations;

        //get the resulting positions
        var result = _bodies.Select
        //for each
        (
            b =>
            //get body transform
            ((Transform2D)Physics2DServer.BodyGetState(b, Physics2DServer.BodyState.Transform))
            //get origin (position)
            .origin
            //snap to grid
            .Snapped(TileSize)
        ).ToList();

        //Note: This is needed to prevent a memory leak
        //dispose of the bodies
        for(int i = 0; i < _bodies.Count; ++i) Physics2DServer.FreeRid(_bodies[i]);
        //dispose of the space
        Physics2DServer.FreeRid(_space);

        //return result
        EmitSignal(nameof(SpreadingFinished), result);
    }
}
