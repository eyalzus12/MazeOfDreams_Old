using System;
using Godot;

public class State : Node
{
    public State() {}

    public override void _Ready()
    {
        Name = GetType().Name.Replace("State", "");
    }

    public override string ToString() => Name;

    public virtual Action<Character> OnStart() => c => {};
    public virtual Action<Character> Loop(float delta) => c => {};
    public virtual Func<Character,string> NextState() => c => "";
    public virtual Action<Character> OnChange(State s) => c => {};
    public virtual Func<Character, IInteractable, bool> CanInteract() => (c,i) => true;
}