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

			var grazing = Mathf.IsZeroApprox(col.Normal.Dot(c.CurrentVelocity));
			
			//dashing and not moving along the wall. bounce.
			if(c.InDash && !grazing)
			{
				//bounce along collision normal
				c.CurrentVelocity = c.CurrentVelocity.Bounce(col.Normal);
				//apply bounce deacceleration
				c.CurrentVelocity *= c.DashBounceForceMultiplier;
			}
			//holding towards or alongside the wall. remove all velocity that is towards the wall.
			else if(col.Normal.Dot(c.InputVector) >= 0 && !c.InputVector.IsZeroApprox())
			{
				c.CurrentVelocity = c.CurrentVelocity.Slide(col.Normal);
			}
			//holding nothing and not moving alongside a wall. reset velocity.
			else if(c.InputVector.IsZeroApprox() && !grazing)
			{
				c.CurrentVelocity = Vector2.Zero;
			}
		}
		
		//update movement
		c.CurrentVelocity = c.CurrentVelocity.MoveToward(c.Speed*c.VelocityVector, c.Acceleration);
	};

	public override Func<Character,string> NextState() => c => (!c.DashInCooldown && Input.IsActionJustPressed("player_dash"))?"Dash":"";
}
