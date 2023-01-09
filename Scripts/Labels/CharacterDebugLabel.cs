using Godot;
using System;
using System.Text;

public class CharacterDebugLabel : Label
{
	public StringBuilder Builder{get; set;} = new StringBuilder();

	public void UpdateText(Character character, float delta)
	{
		if(character is null || !character.DebugActive) return;
		Add("Left", character.Left);
		Add("Right", character.Right);
		Add("Up", character.Up);
		Add("Down", character.Down);
		Add("InputVector", character.InputVector);
		Add("VelocityVector", character.VelocityVector.Round(2));
		Newline();
		Add("State", character.CurrentState);
		Add("StateFrame", character.StateFrame);
		Newline();
		Add("DashInCooldown", character.DashInCooldown);
		Add("InDash", character.InDash);
		Newline();
		Add("Velocity", character.Velocity.Round(2));
		Add("Position", character.Position.Round(2));
		Newline();
		Add("IsOnWall", character.IsOnWall());
		Add("CollisionNormal", (character.GetSlideCount() > 0)?(character.GetSlideCollision(0).Normal):Vector2.Zero);
		Newline();
		Add("CurrentInteractable", character.Interacter?.CurrentInteractable?.GetParent()?.Name??"None");
		Newline();
		Add("FPS", Engine.GetFramesPerSecond());
		Commit();
	}

	public void Commit() {Text = Builder.ToString(); Builder.Clear();}
	public void Add<T>(string name, T property, bool dot = true) => Builder.Append($"{name}{(dot?":":"")} {property.ToString()}    ");
	public void Newline() => Builder.AppendLine();
}
