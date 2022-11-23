using Godot;
using System;
using System.Collections.Generic;

public class DisjointSetUnion
{
    public Dictionary<int,int> Parent{get; private set;} = new Dictionary<int, int>();

    public int this[int i] {get => FindSet(i); set => Union(i, value);}

    public bool MakeSet(int i) => Parent.TryAdd(i, -1);

    public int FindSet(int i) {MakeSet(i); return (Parent[i] < 0)?i:(Parent[i] = FindSet(Parent[i]));}

    public bool SameSet(int i, int j) => FindSet(i) == FindSet(j);

    public bool Union(int i, int j)
    {
        var pi = FindSet(i); var pj = FindSet(j);
        if(pi == pj) return false;

        if(Parent[pi] > Parent[pj])
        {
            Parent[pi] += Parent[pj];
            Parent[pj] = pi;
        }
        else
        {
            Parent[pj] += Parent[pi];
            Parent[pi] = pj;
        }

        return true;
    }
}
