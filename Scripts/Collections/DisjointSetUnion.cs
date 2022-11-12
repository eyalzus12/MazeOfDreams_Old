using Godot;
using System;
using System.Collections.Generic;

public class DisjointSetUnion
{
    public Dictionary<int,int> Parent{get; private set;} = new Dictionary<int, int>();

    public bool MakeSet(int i) => Parent.TryAdd(i, -1);

    public int FindSet(int i)
    {
        MakeSet(i);
        var p = Parent[i];
        if(p < 0) return i;
        else return Parent[i] = FindSet(p);
    }

    public bool SameSet(int i, int j)
    {
        MakeSet(i); MakeSet(j);
        return FindSet(i) == FindSet(j);
    }

    public bool Union(int i, int j)
    {
        var pi = FindSet(i); var pj = FindSet(j);
        if(pi == pj) return false;

        var ic = -Parent[pi];
        var jc = -Parent[pj];

        if(ic < jc)
        {
            Parent[pi] -= jc;
            Parent[pj] = pi;
        }
        else
        {
            Parent[pj] -= ic;
            Parent[pi] = pj;
        }

        return true;
    }
}