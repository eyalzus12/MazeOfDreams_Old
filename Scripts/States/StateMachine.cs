using System;
using System.Collections.Generic;
using System.Linq;
using Godot;

public class StateMachine<T> : Node where T : Godot.Object
{
    public Dictionary<string, State<T>> States{get; set;} = new Dictionary<string, State<T>>();
    public T Entity{get; set;}

    public State<T> CurrentState{get; set;}
    public long StateFrame{get; set;}

    public StateMachine() {}

    public void StoreStates()
    {
        foreach(var n in GetChildren()) if(n is State<T> s) States[s.Name] = s;
    }

    public State<T> this[string s]
    {
        get => States[s];
        set => States[s] = value;
    }

    public void UpdateStateEntities()
    {
        var keysCopy = States.Keys.ToList();
        foreach(var state in keysCopy){States[state].Entity = Entity; States[state].Ready();}
    }

    public void StateUpdate(float delta)
    {
        if(StateFrame == 0) CurrentState.OnStart();
        CurrentState.Loop(delta);
        var next = CurrentState.NextState();
        StateFrame++;
        SetState(next);
    }

    public void SetState(string s)
    {
        if(s == "") return;
        State<T> nextState;
        if(!States.TryGetValue(s, out nextState))
        {
            GD.PushError($"[StateMachine.cs]: Attempt from node {Entity.ToString()} to change to unknown state {s}");
            return;
        }
        
        CurrentState.OnChange(nextState);
        CurrentState = nextState;
        StateFrame = 0;
        Entity.TryEmitSignal("StateChanged", Entity, nextState);
    }
}