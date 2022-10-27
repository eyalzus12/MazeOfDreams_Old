using System;
using Godot;

public static class Extentions
{
    public static void SetTempVariable<T>(this Node n, string variable, float seconds, T start, T end = default(T))
    {
        n.Set(variable, start);
        n.GetTree().CreateTimer(seconds,false).Connect("timeout", n, "set", new Godot.Collections.Array{variable, end});
    }

    public static void SetDeferredTempVariable<T>(this Node n, string variable, float seconds, T start, T end = default(T))
    {
        n.SetDeferred(variable, start);
        n.GetTree().CreateTimer(seconds,false).Connect("timeout", n, "set_deferred", new Godot.Collections.Array{variable, end}, (uint)Godot.Object.ConnectFlags.Deferred);
    }
}