using System;
using Godot;

public class DashState : State
{
	public DashState() : base() {}

	public override Action<Character> OnStart() => c => c.CurrentVelocity = c.DashSpeed * c.VelocityVector;

	public override Action<Character> Loop(float delta) => c => c.SetInputs();
	
	public override Func<Character,string> NextState() => c =>
		(c.StateFrame > (long)Mathf.Ceil(c.DashStartup))?"Base":"";
	
	public override Action<Character> OnChange(State s) => c =>
	{
		c.SetTempVariable(nameof(c.DashInCooldown), c.DashCooldown, true, false);
		c.SetTempVariable(nameof(c.InDash), c.DashTime, true, false);
	};
}
