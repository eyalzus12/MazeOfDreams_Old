using Godot;
using System;
public class Character : KinematicBody2D
{
    [Signal]
	public delegate void StateChanged(Character who, State<Character> to);


	const string DEBUG_LABEL_PATH = "UILayer/DebugLabel";

	const string START_STATE = "Base";

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
	public float DashTime = 0.2f;//seconds

	public bool Left{get; set;}
	public bool Right{get; set;}
	public bool Up{get; set;}
	public bool Down{get; set;}

	public bool DashInCooldown{get; set;}
	public bool InDash{get; set;}

	public Vector2 Velocity{get; set;}

	public CharacterStateMachine States{get; set;}

	public State<Character> CurrentState => States.CurrentState;
	public long StateFrame => States.StateFrame;

	public bool DebugActive{get; set;} = false;
	public CharacterDebugLabel DebugLabel{get; private set;}

	public InteracterComponent Interacter{get; private set;}

	public Timer DashCooldownTimer{get; private set;}
	public Timer InDashTimer{get; private set;}

	public override void _Ready()
	{
		//setup state
		States = GetNodeOrNull<CharacterStateMachine>(nameof(States));
		if(States != null)
		{
			States.StoreStates();
			States.Entity = this;
			States.UpdateStateEntities();
			States.CurrentState = States.States[START_STATE];
		}

		//setup interacter component
		Interacter = GetNodeOrNull<InteracterComponent>(nameof(InteracterComponent));
		if(Interacter != null)
		{
			//this is a hack to get the interacter to always get our current state, and not stay at the first one
			State<Character> GetCurrentState() => CurrentState;
			Interacter.InteractionValidator = (i) => GetCurrentState().CanInteract(i);
		}

		//setup debug label
		DebugLabel = GetNodeOrNull<CharacterDebugLabel>(DEBUG_LABEL_PATH);

		//get timers
		DashCooldownTimer = GetNodeOrNull<Timer>(nameof(DashCooldownTimer));
		DashCooldownTimer.WaitTime = DashCooldown;
		InDashTimer = GetNodeOrNull<Timer>(nameof(InDashTimer));
		InDashTimer.WaitTime = DashTime;
	}

	public override void _PhysicsProcess(float delta)
	{
		//update states
		if(States != null)
		{
			States.StateUpdate(delta);
		}

		//update debug label
		if(DebugLabel != null)
		{
			//toggle debug
			if(Input.IsActionJustPressed(Consts.DEBUG_TOGGLE_INPUT)) DebugActive = !DebugActive;

			DebugLabel.Visible = DebugActive;
			if(DebugActive) DebugLabel.UpdateText(this, delta);	
		}

		//remove inconsequental movements
		Velocity = Velocity.ZeroApproxNormalize();
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
