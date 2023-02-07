using Godot;
using GodotOnReady.Attributes;
using System;
public partial class Character : KinematicBody2D
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

	[Export]
	public float InitialHP = 100f;

	public float CurrentHP{get; set;}

	[Export]
	public float InvincibilityPeriod = 3f;
	[Export]
	public float StunFriction = 10f;

	public int Direction{get; set;}

	public float StunTime{get; set;}

	public bool Left{get; set;}
	public bool Right{get; set;}
	public bool Up{get; set;}
	public bool Down{get; set;}

	public bool DashInCooldown{get; set;}
	public bool InDash{get; set;}

	public Vector2 Velocity{get; set;}

	[OnReadyGet(nameof(States))]
	public CharacterStateMachine States{get; set;}

	public State<Character> CurrentState => States.CurrentState;
	public long StateFrame => States.StateFrame;

	public bool DebugActive{get; set;} = false;
	[OnReadyGet(DEBUG_LABEL_PATH, OrNull = true)]
	public CharacterDebugLabel DebugLabel{get; private set;}

	[OnReadyGet(nameof(InteracterComponent))]
	public InteracterComponent Interacter{get; private set;}

	[OnReadyGet(nameof(CharacterHurtbox))]
	public Hurtbox CharacterHurtbox{get; set;}


	[OnReadyGet(nameof(DashCooldownTimer))]
	public Timer DashCooldownTimer{get; private set;}

	[OnReadyGet(nameof(InDashTimer))]
	public Timer InDashTimer{get; private set;}

	[OnReadyGet(nameof(InvincibilityTimer))]
	public Timer InvincibilityTimer{get; set;}

	[OnReadyGet(nameof(CharacterAnimationPlayer))]
	public AnimationPlayer CharacterAnimationPlayer{get; set;}

	[OnReadyGet(nameof(CharacterSwordBase))]
	public Node2D CharacterSwordBase{get; set;}

	[OnReadyGet("CharacterSwordBase/CharacterSword")]
	public Sword CharacterSword{get; set;}
	[OnReadyGet(nameof(CharacterSprite))]
	public Sprite CharacterSprite{get; set;}

	[OnReady]
	public virtual void Setup()
	{
        CurrentHP = InitialHP;

		States.StoreStates();
		States.Entity = this;
		States.UpdateStateEntities();
		States.CurrentState = States.States[START_STATE];
		
		//this is a hack to get the interacter to always get our current state, and not stay at the first one
		State<Character> GetCurrentState() => CurrentState;
		Interacter.InteractionValidator = (i) => GetCurrentState().CanInteract(i);

		DashCooldownTimer.WaitTime = DashCooldown;
		InDashTimer.WaitTime = DashTime;
	}

	public override void _PhysicsProcess(float delta)
	{
		//update states
		States?.StateUpdate(delta);

		//update debug label
		if(DebugLabel != null)
		{
			//toggle debug
			if(Input.IsActionJustPressed(Consts.DEBUG_TOGGLE_INPUT)) DebugActive = !DebugActive;

			DebugLabel.Visible = DebugActive;
			if(DebugActive) DebugLabel.UpdateText(this, delta);	
		}

		//TODO: check for state
		if(Input.IsActionJustPressed(Consts.ATTACK_INPUT))
			CharacterSword.Attack();

		//remove inconsequental movements
		Velocity = Velocity.ZeroApproxNormalize();

		var newDirection = (GetGlobalMousePosition().x>=GlobalPosition.x)?1:-1;
		CharacterSwordBase.Scale = new Vector2(newDirection,1);
		CharacterHurtbox.Position = new Vector2(newDirection,1);
		CharacterSprite.FlipH = newDirection==-1;
		Direction = newDirection;
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

	public virtual void OnGotHit(Area2D area)
	{
		if(area is Hitbox hitbox)
		{
			CurrentHP -= hitbox.Damage;
			StunTime = hitbox.StunTime;
			States.SetState("Hurt");
			Velocity += (area.GlobalPosition.DirectionTo(GlobalPosition))*hitbox.Pushback;
		}
	}

	public virtual void OnInvincibilityEnd()
	{
		CharacterHurtbox.Enable();
		CharacterAnimationPlayer.Play("RESET");
        CharacterAnimationPlayer.Advance(0);
		CharacterAnimationPlayer.Stop(true);
	}
}
