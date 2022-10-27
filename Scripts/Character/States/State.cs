using System;
using Godot;

public class State : Node
{
    public State() {}

    public virtual Action<Character> OnStart() => c => {};
    public virtual Action<Character> Loop(float delta) => c => {};
    public virtual Func<Character,string> NextState() => c => "";
    public virtual Action<Character> OnChange(State s) => c => {};
}