using Godot;
using System;

public class InteracterComponent : Area2D
{
	public Func<InteractableComponent, bool> InteractionValidator{get; set;} = (i) => true;

    private InteractableComponent _currentInteractable;
	public InteractableComponent CurrentInteractable{get => _currentInteractable; set
	{
		if(
			_currentInteractable is null || //no current interactable
			value is null || //overriding current interactable
			//if not overriding and current interactable exists,
			(
				//ensure new interactable has proper priority. either
				(
					//strictly higher priority
					value.InteractionPriority > _currentInteractable.InteractionPriority ||
					//or
					(
						//same priority
						value.InteractionPriority == _currentInteractable.InteractionPriority &&
						//and closer
						GlobalPosition.DistanceSquaredTo(value.GlobalPosition) < GlobalPosition.DistanceSquaredTo(_currentInteractable.GlobalPosition)
					)
				) &&
				//ensure we can interact with new interactable
				InteractionValidator(value)
			)
		)
			_currentInteractable = value;
	}}

    public override void _PhysicsProcess(float delta)
    {
        //if can't interact with current, leave it
		if(!InteractionValidator(CurrentInteractable)) CurrentInteractable = null;

		//if has an interactable and interact is pressed, do interaction action
		if(CurrentInteractable != null && Input.IsActionJustPressed(Consts.INTERACT_INPUT))
			CurrentInteractable.OnInteract(this);
    }
}
