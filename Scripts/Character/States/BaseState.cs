using System;
using Godot;

public class BaseState : State
{
	public BaseState() : base() {}

	//public override Action<Character> OnStart() => c => {};

	public override Action<Character> Loop(float delta) => c =>
	{
		//apply movement
		c.MoveAndSlide(c.CurrentVelocity, Vector2.Zero);

		//detect bounce
		if(c.DashBounceActive && c.IsOnWall())
		{
			//get first collision
			var col = c.GetSlideCollision(0);
			//bounce along collision normal
			c.CurrentVelocity = c.CurrentVelocity.Bounce(col.Normal);
			//apply bounce deacceleration
			c.CurrentVelocity = c.CurrentVelocity.MoveToward(Vector2.Zero, c.DashBounceDeacceleration);
		}

		//update inputs and movement
		c.SetInputs();
		c.CurrentVelocity = c.CurrentVelocity.MoveToward(c.Speed*c.VelocityVector, c.Acceleration);
	};

	public override Func<Character,string> NextState() => c => (!c.DashInCooldown && Input.IsActionJustPressed("player_dash"))?"Dash":"";

	//public override Action<Character> OnChange(State s) => c => {};
}
