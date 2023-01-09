using System;
using Godot;

public class BaseState : State
{
	public BaseState() : base() {}

	public override Action<Character> Loop(float delta) => c =>
	{
		//apply movement
		c.MoveAndSlide(c.Velocity, Vector2.Zero);
		
		//update inputs
		c.SetInputs();
		
		if(c.IsOnWall())
		{
			//get first collision
			var col = c.GetSlideCollision(0);

			var grazing = Mathf.IsZeroApprox(col.Normal.Dot(c.Velocity));
			
			//dashing and not moving along the wall. bounce.
			if(c.InDash && !grazing)
			{
				//bounce along collision normal
				c.Velocity = c.Velocity.Bounce(col.Normal);
				//apply bounce deacceleration
				c.Velocity *= c.DashBounceForceMultiplier;
			}
			//holding towards or alongside the wall. remove all velocity that is towards the wall.
			else if(col.Normal.Dot(c.InputVector) >= 0 && !c.InputVector.IsZeroApprox())
			{
				c.Velocity = c.Velocity.Slide(col.Normal);
			}
			//holding nothing and not moving alongside a wall. reset velocity.
			else if(c.InputVector.IsZeroApprox() && !grazing)
			{
				c.Velocity = Vector2.Zero;
			}
		}
		
		//update movement
		c.Velocity = c.Velocity.MoveToward(c.Speed*c.VelocityVector, c.Acceleration);
	};

	public override Func<Character,string> NextState() => c => (!c.DashInCooldown && Input.IsActionJustPressed(Consts.DASH_INPUT))?"Dash":"";
}
