using System;
using Godot;

public class BaseState : State
{
	public BaseState() : base() {}

	public override Action<Character> Loop(float delta) => c =>
	{
		//apply movement
		c.MoveAndSlide(c.CurrentVelocity, Vector2.Zero);
		
		//update inputs
		c.SetInputs();
		
		if(c.IsOnWall())
		{
			//get first collision
			var col = c.GetSlideCollision(0);

			//detect bounce
			if(c.InDash && !Mathf.IsZeroApprox(col.Normal.Dot(c.CurrentVelocity)))
			{
				//bounce along collision normal
				c.CurrentVelocity = c.CurrentVelocity.Bounce(col.Normal);
				//apply bounce deacceleration
				c.CurrentVelocity *= c.DashBounceForceMultiplier;
			}
		}
		
		//update movement
		c.CurrentVelocity = c.CurrentVelocity.MoveToward(c.Speed*c.VelocityVector, c.Acceleration);
	};

	public override Func<Character,string> NextState() => c => (!c.DashInCooldown && Input.IsActionJustPressed("player_dash"))?"Dash":"";
}
