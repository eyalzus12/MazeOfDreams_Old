using System;
using Godot;

public class DashState : State<Character>
{
	public DashState() : base() {}

	public override void Loop(float delta)
	{
		//calculate desired acceleration
		var dashAcceleration = Entity.DashSpeed/Mathf.Ceil(Entity.DashStartup);
		//apply acceleration
		Entity.Velocity = Entity.Velocity.MoveToward(Entity.DashSpeed * Entity.VelocityVector, dashAcceleration);
		//apply movement
		Entity.MoveAndSlide(Entity.Velocity, Vector2.Zero);
	}
	
	//transition into Base if more than DashStartup (rounded up) frames passed
	public override string NextState() => (Entity.StateFrame > Mathf.Ceil(Entity.DashStartup))?"Base":"";
	
	//set dash cooldown and dash bounce timers
	public override void OnChange(State<Character> s)
	{
		Entity.DashInCooldown = true;
		Entity.DashCooldownTimer.Start();

		Entity.InDash = true;
		Entity.InDashTimer.Start();
	}

	//can't interact during dash startup
	public override bool CanInteract(InteractableComponent ic) => false;
}
