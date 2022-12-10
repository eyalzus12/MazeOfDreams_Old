using System;
using System.Collections.Generic;
using System.Linq;
using Godot;

public static class Extentions
{
    public static Vector2 Center(this Rect2 rec) => rec.Position + rec.Size/2f;
		
	public static Rect2 Clamp(this Rect2 rec, float mx, float Mx, float my, float My)
	{
		var rpos = new Vector2(mx,my);
		var rend = new Vector2(Mx,My);
		var rsize = (rend-rpos).Abs();
		var r = new Rect2(rpos,rsize);
		return rec.Clip(r);
	}
    
    public static void DrawShape(this CanvasItem ci, Shape2D shape, Color color) => shape.Draw(ci.GetCanvasItem(), color);

    public static Rect2 RectWithAll(this IEnumerable<Vector2> ev)
	{
		(Vector2 pos, Vector2 end) = ev.Aggregate<Vector2, (Vector2,Vector2)>((Vector2.Inf,-Vector2.Inf), (a,v) => (a.Item1.Min(v), a.Item2.Max(v)));
		var size = (end-pos).Abs();
		return new Rect2(pos,size);
	}

    public static Vector2 Max(this Vector2 v1, Vector2 v2) => new Vector2(Math.Max(v1.x,v2.x), Math.Max(v1.y,v2.y));
    public static Vector2 Min(this Vector2 v1, Vector2 v2) => new Vector2(Math.Min(v1.x,v2.x), Math.Min(v1.y,v2.y));

    public static bool EqualsIgnoreCase(this string s1, string s2) => string.Equals(s1, s2,  StringComparison.OrdinalIgnoreCase);

    public static Vector2 NormalizedOrZero(this Vector2 v) => (v == Vector2.Zero)?Vector2.Zero:v.Normalized();
    public static Vector2 Round(this Vector2 v, int digits) => new Vector2(
        Round(v.x, digits),
        Round(v.y, digits)
    );

    public static bool IsZeroApprox(this Vector2 v) => Mathf.IsZeroApprox(v.x) && Mathf.IsZeroApprox(v.y);

    public static float ZeroApproxNormalize(this float f) => Mathf.IsZeroApprox(f)?0f:f;
    public static Vector2 ZeroApproxNormalize(this Vector2 v) => new Vector2(v.x.ZeroApproxNormalize(), v.y.ZeroApproxNormalize());

    public static float Round(float f, int digits) => (float)Math.Round(f,digits);

    public static bool TryAdd<TKey, TValue>(this IDictionary<TKey,TValue> d, TKey key, TValue @value)
    {
        if(d.ContainsKey(key)) return false;
        d.Add(key, @value);
        return true;
    }

    public static TValue GetValueOrDefault<TKey, TValue>(this IDictionary<TKey, TValue> d, TKey key, TValue @default = default(TValue))
    {
        TValue result;
        if(d.TryGetValue(key, out result)) return result;
        else return @default;
    }

    public static bool InstanceValid(this Godot.Object go) => Godot.Object.IsInstanceValid(go);

    public static IEnumerable<T> GetChildren<T>(this Node n) => n.GetChildren().OfType<T>();

    public static Dictionary<TGroup, List<TObject>> GroupByToDictionary<TGroup, TObject>(this IEnumerable<TObject> e, Func<TObject, TGroup> grouper) => e.GroupBy(grouper).ToDictionary(k=>k.Key, g=>g.ToList());

    public static Vector2 WithLength(this Vector2 v, float length) => v.NormalizedOrZero() * length;
    public static Vector2 WithLength(this Vector2 v1, Vector2 v2) => v1.WithLength(v2.Length());

    public static float RandfExclusive(this RandomNumberGenerator rng) => rng.RandfRange(0f, 1f-Mathf.Epsilon);

    public static Vector2 GetRandomPointInCircle(this RandomNumberGenerator rng, float radius)
    {
        var t = 2*Mathf.Pi*rng.RandfExclusive();
        var u = rng.RandfExclusive() + rng.RandfExclusive();
        var r = (u > 1)?(2f-u):u;
        return new Vector2(Mathf.Cos(t), Mathf.Sin(t))*radius*r;
    }

    public static T Choice<T>(this RandomNumberGenerator rng, IEnumerable<T> e)
    {
        var l = e.ToList();
        return l[rng.RandiRange(0, l.Count-1)];
    }

    public static List<T> MultiChoice<T>(this RandomNumberGenerator rng, IEnumerable<T> e, int amount)
    {
        var l = e.ToList();
        if(amount >= l.Count) throw new IndexOutOfRangeException();
        var result = new List<T>();
        for(int i = 0; i < amount; ++i)
        {
            var c = rng.RandiRange(i, l.Count-1);
            l.Swap(i, c);
            result.Add(l[i]);
        }
        return result;
    }

    public static void Swap<T>(this IList<T> list, int indexA, int indexB)
    {
        T tmp = list[indexA];
        list[indexA] = list[indexB];
        list[indexB] = tmp;
    }

    public static float GridDistanceTo(this Vector2 v1, Vector2 v2) => Mathf.Abs(v1.x-v2.x) + Mathf.Abs(v1.y-v2.y);

    public static void TimePhysicsAction(this Node n, float seconds, string action)
    {
        var timer = new Timer();
        timer.WaitTime = seconds;
        timer.ProcessMode = Timer.TimerProcessMode.Physics;
        n.AddChild(timer);
        timer.Connect("timeout", n, action);
        timer.Connect("timeout", timer, "queue_free");//remove timer after that time
        timer.Start();
    }

    public static void Deconstruct<TKey, TValue>(this KeyValuePair<TKey, TValue> kvp, out TKey key, out TValue value)
    {key = kvp.Key; value = kvp.Value;}

    public static void Deconstruct(this Vector2 v, out float x, out float y) {x = v.x; y = v.y;}
    public static void Deconstruct(this Vector3 v, out float x, out float y, out float z) {x = v.x; y = v.y; z = v.z;}
    public static void Deconstruct(this Quat v, out float x, out float y, out float z, out float w) {x = v.x; y = v.y; z = v.z; w = v.w;}

    public static void Deconstruct(this Rect2 r, out Vector2 pos, out Vector2 end) {pos = r.Position; end = r.End;}

    public static void ForEach<T>(this IEnumerable<T> e, Action<T> a) {foreach(var h in e) a(h);}

    public static void TryInvokeValue<TKey, TValue>(this IDictionary<TKey, TValue> d, TKey key, Action<TValue> a)
    {
        TValue value; if(d.TryGetValue(key, out value)) a(value);
    }

    ///<summary>
    ///Moves a position between two <see cref="Godot.TileMap"/>s.
    ///</summary>
    ///<param name="originTileMap">The <see cref="Godot.TileMap"/> where the position originated from.</param>
    ///<param name="targetTileMap">The <see cref="Godot.TileMap"/> to move the position to.</param>
    ///<param name="position">The position to move, in originTileMap's map coordinates.</param>
    ///<returns>The given position in targetTileMap's map coordinates.</returns>
    public static Vector2 MapToMap(this TileMap originTileMap, TileMap targetTileMap, Vector2 position) => targetTileMap.WorldToMap(targetTileMap.ToLocal(originTileMap.ToGlobal(originTileMap.MapToWorld(position))));
}