using System;
using System.Collections.Generic;
using Godot;

public class StateMachine : Node
{
    public Dictionary<string, State> States{get; set;} = new Dictionary<string, State>();

    public override void _Ready()
    {
        foreach(var n in GetChildren()) if(n is State s) States[s.Name] = s;
    }

    public State this[string s]
    {
        get => States[s];
        set => States[s] = value;
    }

    public StateMachine() {}

    public void StateUpdate(Character c, float delta)
    {
        if(c.StateFrame == 0) c.CurrentState.OnStart()(c);
        c.CurrentState.Loop(delta)(c);
        var next = c.CurrentState.NextState()(c);
        c.StateFrame++;
        if(next != "")
        {
            State nextState;
            if(!States.TryGetValue(next, out nextState))
            {
                GD.PushError($"[StateMachine.cs]: Attempt from character {c.ToString()} to change to unknown state {next}");
                return;
            }
            
            c.OnStateChanged(nextState);
        }
    } 
}