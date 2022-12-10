using System;
using Godot;

public class DashState : State
{
	public DashState() : base() {}

	public override Action<Character> Loop(float delta) => c => 
	{
		//calculate desired acceleration
		var dashAcceleration = c.DashSpeed/Mathf.Ceil(c.DashStartup);
		//apply acceleration
		c.CurrentVelocity = c.CurrentVelocity.MoveToward(c.DashSpeed * c.VelocityVector, dashAcceleration);
		//apply movement
		c.MoveAndSlide(c.CurrentVelocity, Vector2.Zero);
	};
	
	//transition into Base if more than DashStartup (rounded up) frames passed
	public override Func<Character,string> NextState() => c =>
		(c.StateFrame > Mathf.Ceil(c.DashStartup))?"Base":"";
	
	//set dash cooldown and dash bounce timers
	public override Action<Character> OnChange(State s) => c =>
	{
		c.DashInCooldown = true;
		c.DashCooldownTimer.Start();

		c.InDash = true;
		c.InDashTimer.Start();
	};

	//can't interact during dash startup
	public override Func<Character, InteractableComponent, bool> CanInteract() => (c, i) => false;
}
