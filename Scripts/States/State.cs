using System;
using Godot;

public class State<T> : Node
{
    public State() {}

    public T Entity{get; set;}

    public override string ToString() => Name;

    public virtual void Ready(){}
    public virtual void OnStart(){}
    public virtual void Loop(float delta){}
    public virtual string NextState() => "";
    public virtual void OnChange(State<T> s){}
    public virtual bool CanInteract(InteractableComponent ic) => true;
}