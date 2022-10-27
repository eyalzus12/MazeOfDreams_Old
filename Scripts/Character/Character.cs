using Godot;
using System;
public class Character : KinematicBody2D
{
    [Signal]
    public delegate void StateUpdate(Character c, float delta);

    [Export]
    public float Speed = 300f;
    [Export]
    public float Acceleration = 50f;
    [Export]
    public float DashStartup = 2f;
    [Export]
    public float DashSpeed = 1000f;
    [Export]
    public float DashBounceDeacceleration = 10f;
    [Export]
    public float DashCooldown = 0.5f;//seconds
    [Export]
    public float DashBounceWindow = 0.3f;//seconds

	public bool Left{get; set;}
    public bool Right{get; set;}
    public bool Up{get; set;}
    public bool Down{get; set;}

    public bool DashInCooldown{get; set;}
    public bool DashBounceActive{get; set;}

    public Vector2 CurrentVelocity{get; set;}

    public State CurrentState{get; set;}
    public long StateFrame{get; set;}

    public override void _Ready()
    {
        var stateMachine = GetTree().Root.GetNode<StateMachine>("StateMachine");
        Connect("StateUpdate", stateMachine, "StateUpdate");
        CurrentState = stateMachine["Base"];
    }

    public override void _PhysicsProcess(float delta)
    {
        EmitSignal("StateUpdate", this, delta);
    }

    public Vector2 InputVector => new Vector2(Right?1:Left?-1:0, Down?1:Up?-1:0);
    public Vector2 VelocityVector => (InputVector == Vector2.Zero)?Vector2.Zero:InputVector.Normalized();

    public void SetInputs()
    {
        SetHorizontalInputs();
        SetVerticalInputs();
    }

    public void SetHorizontalInputs()
    {
        if(Input.IsActionJustPressed("player_left")) {Left = true; Right = false;}
        if(Input.IsActionJustPressed("player_right")) {Left = false; Right = true;}
        if(!Input.IsActionPressed("player_left")) Left = false;
        if(!Input.IsActionPressed("player_right")) Right = false;
        if(Input.IsActionPressed("player_left") && !Right) Left = true;
        if(Input.IsActionPressed("player_right") && !Left) Right = true;
    }
    
    public void SetVerticalInputs()
    {
        if(Input.IsActionJustPressed("player_up")) {Up = true; Down = false;}
        if(Input.IsActionJustPressed("player_down")) {Up = false; Down = true;}
        if(!Input.IsActionPressed("player_up")) Up = false;
        if(!Input.IsActionPressed("player_down")) Down = false;
        if(Input.IsActionPressed("player_up") && !Down) Up = true;
        if(Input.IsActionPressed("player_down") && !Up) Down = true;
    }
}
