using System;

public class WeightedGraphEdge : IComparable<WeightedGraphEdge>
{
    public int First{get; set;}
    public int Second{get; set;}
    public float Weight{get; set;}

    public WeightedGraphEdge(int first, int second, float weight)
    {
        First = first;
        Second = second;
        Weight = weight;
    }

    public int CompareTo(WeightedGraphEdge w) => Weight.CompareTo(w.Weight);
}
