using System;
using System.Collections.Generic;
using System.Linq;
using Godot;

public class WeightedGraph
{
    public int NodeCount{get; set;} = 0;
    public List<WeightedGraphEdge> Edges{get; set;} = new List<WeightedGraphEdge>();
    public int EdgeCount => Edges.Count;

    public WeightedGraph() {}

    public WeightedGraph(int nodeCount)
    {
        NodeCount = nodeCount;
    }

    public WeightedGraph(int nodeCount, IEnumerable<WeightedGraphEdge> edges)
    {
        NodeCount = nodeCount;
        Edges = edges.ToList();
    }

    public static WeightedGraph GenerateFromPointList(List<Vector2> points, HashSet<(int,int)> illegals)
    {
        var triangulation = Geometry.TriangulateDelaunay2d(points.ToArray());
        if(triangulation.Length == 0) GD.PushError("Room triangluation failed");
        var result = new WeightedGraph(points.Count);
        var edgeSet = new HashSet<(int,int)>();
        for(int i = 0; i < triangulation.Length; i += 3)
        {
            var first = triangulation[i];
            var second = triangulation[i+1];
            var third = triangulation[i+2];

            if(
                !edgeSet.Contains((first,second)) &&
                !edgeSet.Contains((second,first)) &&
                !illegals.Contains((first,second)) &&
                !illegals.Contains((second,first))
                )
            {
                var dist = points[first].DistanceSquaredTo(points[second]);
                result.Edges.Add(new WeightedGraphEdge(first, second, dist));
                edgeSet.Add((first,second));
            }
            
            if(
                !edgeSet.Contains((third,second)) &&
                !edgeSet.Contains((second,third)) &&
                !illegals.Contains((third,second)) &&
                !illegals.Contains((second,third))
                )
            {
                var dist = points[third].DistanceSquaredTo(points[second]);
                result.Edges.Add(new WeightedGraphEdge(third, second, dist));
                edgeSet.Add((third,second));
            }
            
            if(
                !edgeSet.Contains((first,third)) &&
                !edgeSet.Contains((third,first)) &&
                !illegals.Contains((first,third)) &&
                !illegals.Contains((third,first))
                )
            {
                var dist = points[first].DistanceSquaredTo(points[third]);
                result.Edges.Add(new WeightedGraphEdge(first, third, dist));
                edgeSet.Add((first,third));
            }
        }

        return result;
    }

    public WeightedGraph Kurskal()
    {
        Edges.Sort();
        var dsu = new DisjointSetUnion();
        var result = new WeightedGraph(NodeCount);

        foreach(var edge in Edges) if(dsu[edge.First] != dsu[edge.Second])
        {
            result.Edges.Add(edge);
            dsu[edge.First] = edge.Second;
        }

        return result;
    }

    public WeightedGraph RandomKruskal(RandomNumberGenerator rng, float extraChance, float curveMult)
    {
        Edges.Sort();
        var dsu = new DisjointSetUnion();
        var result = new WeightedGraph(NodeCount);
        var edgeSet = new HashSet<WeightedGraphEdge>();

        foreach(var edge in Edges) if(dsu[edge.First] != dsu[edge.Second])
        {
            result.Edges.Add(edge);
            dsu[edge.First] = edge.Second;
            edgeSet.Add(edge);
        }

        foreach(var edge in Edges)
        if(
            !edgeSet.Contains(edge) &&
            rng.RandfExclusive() < extraChance*(1f-Mathf.Tanh(curveMult*edge.Weight))
        )
        {
            result.Edges.Add(edge);
        }

        return result;
    }
}