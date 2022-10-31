using Godot;
using System;
public class Character : KinematicBody2D
{
    const string STATE_MACHINE_PATH = "StateMachine";
    const string DEBUG_LABEL_PATH = "UILayer/DebugLabel";

    const string START_STATE = "Base";

    [Signal]
    public delegate void CharacterUpdate(Character c, float delta);

    [Export]
    public float Speed = 300f;
    [Export]
    public float Acceleration = 50f;
    [Export]
    public float DashStartup = 2f;
    [Export]
    public float DashSpeed = 1000f;
    [Export]
    public float DashBounceForceMultiplier = 1.3f;
    [Export]
    public float DashCooldown = 0.5f;//seconds
    [Export]
    public float DashBounceWindow = 0.2f;//seconds

	public bool Left{get; set;}
    public bool Right{get; set;}
    public bool Up{get; set;}
    public bool Down{get; set;}

    public bool DashInCooldown{get; set;}
    public bool DashBounceActive{get; set;}

    public Vector2 CurrentVelocity{get; set;}

    public State CurrentState{get; set;}
    public long StateFrame{get; set;}

    public bool DebugActive{get; set;} = false;
    public CharacterDebugLabel DebugLabel{get; set;}

    public override void _Ready()
    {
        //setup state
        var stateMachine = GetTree().Root.GetNode<StateMachine>(STATE_MACHINE_PATH);
        Connect(nameof(CharacterUpdate), stateMachine, nameof(stateMachine.StateUpdate));
        CurrentState = stateMachine[START_STATE];

        //setup debug label
        DebugLabel = GetNode<CharacterDebugLabel>(DEBUG_LABEL_PATH);
    }

    public override void _PhysicsProcess(float delta)
    {
        //cause state update
        EmitSignal(nameof(CharacterUpdate), this, delta);

        //toggle debug
        if(Input.IsActionJustPressed(Consts.DEBUG_TOGGLE_INPUT)) DebugActive = !DebugActive;

        //update debug label
        DebugLabel.Visible = DebugActive;
        if(DebugActive) DebugLabel.UpdateText(this, delta);

        //remove inconsequental movements
        CurrentVelocity = CurrentVelocity.ZeroApproxNormalize();
    }
    
    public Vector2 LeftInputVector => Left?Vector2.Left:Vector2.Zero;
    public Vector2 RightInputVector => Right?Vector2.Right:Vector2.Zero;
    public Vector2 HorizontalInputVector => LeftInputVector + RightInputVector;
    public Vector2 UpInputVector => Up?Vector2.Up:Vector2.Zero;
    public Vector2 DownInputVector => Down?Vector2.Down:Vector2.Zero;
    public Vector2 VerticalInputVector => UpInputVector + DownInputVector;
    public Vector2 InputVector => HorizontalInputVector + VerticalInputVector;
    public Vector2 VelocityVector => InputVector.NormalizedOrZero();

    public void SetInputs()
    {
        SetHorizontalInputs();
        SetVerticalInputs();
    }

    public void SetHorizontalInputs()
    {
        if(Input.IsActionJustPressed(Consts.LEFT_INPUT)) {Left = true; Right = false;}
        if(Input.IsActionJustPressed(Consts.RIGHT_INPUT)) {Left = false; Right = true;}
        if(!Input.IsActionPressed(Consts.LEFT_INPUT)) Left = false;
        if(!Input.IsActionPressed(Consts.RIGHT_INPUT)) Right = false;
        if(Input.IsActionPressed(Consts.LEFT_INPUT) && !Right) Left = true;
        if(Input.IsActionPressed(Consts.RIGHT_INPUT) && !Left) Right = true;
    }
    
    public void SetVerticalInputs()
    {
        if(Input.IsActionJustPressed(Consts.UP_INPUT)) {Up = true; Down = false;}
        if(Input.IsActionJustPressed(Consts.DOWN_INPUT)) {Up = false; Down = true;}
        if(!Input.IsActionPressed(Consts.UP_INPUT)) Up = false;
        if(!Input.IsActionPressed(Consts.DOWN_INPUT)) Down = false;
        if(Input.IsActionPressed(Consts.UP_INPUT) && !Down) Up = true;
        if(Input.IsActionPressed(Consts.DOWN_INPUT) && !Up) Down = true;
    }
}
