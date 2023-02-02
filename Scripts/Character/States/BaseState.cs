using System;
using Godot;

public class BaseState : State<Character>
{
	public BaseState() : base() {}

	public override void Loop(float delta)
	{
		//apply movement
		Entity.MoveAndSlide(Entity.Velocity, Vector2.Zero);
		
		//update inputs
		Entity.SetInputs();
		
		if(Entity.IsOnWall())
		{
			//get first collision
			var col = Entity.GetSlideCollision(0);

			var grazing = Mathf.IsZeroApprox(col.Normal.Dot(Entity.Velocity));
			
			//dashing and not moving along the wall. bounce.
			if(Entity.InDash && !grazing)
			{
				//bounce along collision normal
				Entity.Velocity = Entity.Velocity.Bounce(col.Normal);
				//apply bounce deacceleration
				Entity.Velocity *= Entity.DashBounceForceMultiplier;
			}
			//holding towards or alongside the wall. remove all velocity that is towards the wall.
			else if(col.Normal.Dot(Entity.InputVector) >= 0 && !Entity.InputVector.IsZeroApprox())
			{
				Entity.Velocity = Entity.Velocity.Slide(col.Normal);
			}
			//holding nothing and not moving alongside a wall. reset velocity.
			else if(Entity.InputVector.IsZeroApprox() && !grazing)
			{
				Entity.Velocity = Vector2.Zero;
			}
		}
		
		//update movement
		Entity.Velocity = Entity.Velocity.MoveToward(Entity.Speed*Entity.VelocityVector, Entity.Acceleration);
	}

	public override string NextState() => (!Entity.DashInCooldown && Input.IsActionJustPressed(Consts.DASH_INPUT))?"Dash":"";
}
