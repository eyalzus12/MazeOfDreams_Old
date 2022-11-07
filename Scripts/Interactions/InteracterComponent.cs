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
			//ensure change is valid
			(
				//ensure new interactable has higher priority
				value.InteractionPriority > _currentInteractable.InteractionPriority &&
				//ensure can interact with new interactable
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
