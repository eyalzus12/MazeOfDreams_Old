using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public partial class RoomSpreader : Node2D
{
    const float WAIT_TIME = 2;

    [Signal]
    public delegate void SpreadingFinishedEventHandler(Godot.Collections.Array<Vector2> positions);

    public Vector2 TileSize{get; set;} = 64*Vector2.One;
    public int SpawnRadius{get; set;} = 50;
    private List<Rid> _bodies = new();
    public List<List<(Transform2D, Shape2D)>> Shapes{get; set;}
    public RandomNumberGenerator RNG{get; private set;}

    private int _engineIterations;
    private Rid _space;

    public RoomSpreader() {}
    public RoomSpreader(Vector2 tileSize, int spawnRadius, IEnumerable<IEnumerable<(Transform2D, Shape2D)>> shapes)
    {
        Shapes = shapes.Select(l=>l.ToList<(Transform2D, Shape2D)>()).ToList<List<(Transform2D, Shape2D)>>();
        TileSize = tileSize;
        SpawnRadius = spawnRadius;
    }

    public override void _Ready()
    {
        //save physics speed for later
        _engineIterations = Engine.PhysicsTicksPerSecond;

        //get RNG
        RNG = GetTree().Root.GetNode<Randomizer>(nameof(Randomizer)).RNG;

        //create a space
        _space = PhysicsServer2D.SpaceCreate();
        
        for(int i = 0; i < Shapes.Count; ++i)
        {
            //create a body
            var body = PhysicsServer2D.BodyCreate();
            //set it to be rigid, and not rotate
            PhysicsServer2D.BodySetMode(body, PhysicsServer2D.BodyMode.RigidLinear);
            //put inside the space
            PhysicsServer2D.BodySetSpace(body, _space);
            //set it to a random position
            var position = RNG.GetRandomPointInCircle(SpawnRadius);
            PhysicsServer2D.BodySetState(body, PhysicsServer2D.BodyState.Transform, new Transform2D(0f, position));
            //remove gravity
            PhysicsServer2D.BodySetParam(body, PhysicsServer2D.BodyParameter.GravityScale, 0f);
            //set its shape
            var shapes = Shapes[i];
            for(int j = 0; j < shapes.Count; ++j)
            {
                (Transform2D trans, Shape2D shape) = shapes[j];
                shape.CustomSolverBias = 1f;
                PhysicsServer2D.BodyAddShape(body, shape.GetRid(), trans);
            }
           
            //add to the list
            _bodies.Add(body);
        }
        //make the space active
        PhysicsServer2D.SpaceSetActive(_space, true);

        //increase physics speed
        //Engine.PhysicsTicksPerSecond = 240;
        //in 2 seconds, gather positions
        this.TimePhysicsAction(WAIT_TIME, nameof(OnTimeout));
    }

    public void OnTimeout()
    {
        //restore physics speed
        Engine.PhysicsTicksPerSecond = _engineIterations;
        //make space inactive
        PhysicsServer2D.SpaceSetActive(_space, false);

        //get the resulting positions
        var result = new Godot.Collections.Array<Vector2>(_bodies.Select
        //for each
        (
            b =>
            //get body transform
            PhysicsServer2D.BodyGetState(b, PhysicsServer2D.BodyState.Transform).AsTransform2D()
            //get origin (position)
            .Origin
            //snap to grid
            .Snapped(TileSize)
        ));

        //the references for the bodies and space still exist
        //so we need to get rid of them to prevent a memory leak

        //dispose of the bodies
        for(int i = 0; i < _bodies.Count; ++i) PhysicsServer2D.FreeRid(_bodies[i]);
        //dispose of the space
        PhysicsServer2D.FreeRid(_space);

        //return result
        
        EmitSignal(nameof(SpreadingFinished), result);
    }
}
