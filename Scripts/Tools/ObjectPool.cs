using Godot;
using System;
using System.Collections.Generic;

public class ObjectPool<T> : Node where T : Godot.Object
{
    [Export]
    public int ExtraLoadAmount{get; set;} = 5;

    public Dictionary<string, PackedScene> DefaultLoaders{get; set;} = new Dictionary<string, PackedScene>();
    public Dictionary<string, Queue<T>> PoolDictionary{get; set;} = new Dictionary<string, Queue<T>>();

    public ObjectPool() {}

    public PackedScene this[string identifier]
    {
        get => DefaultLoaders[identifier];
        set => DefaultLoaders[identifier] = value;
    }

    public bool ContainsLoader(string identifier) => DefaultLoaders.ContainsKey(identifier);

    public Queue<T> GetPooledObjects(string indentifier) => PoolDictionary[indentifier];

    public int PooledObjectCount(string identifier)
    {
        Queue<T> queue;
        if(!PoolDictionary.TryGetValue(identifier, out queue)) return 0;
        return queue.Count;
    }
    
    public void PoolObject(string identifier, T obj)
    {
        PoolDictionary.TryAdd(identifier, new Queue<T>());
        PoolDictionary[identifier].Enqueue(obj);
    }

    public List<T> GetObjects(string identifier, int amount, int loadAmount = 0, PackedScene loaderOverride = null)
    {
        var result = new List<T>();
        PoolDictionary.TryAdd(identifier, new Queue<T>());
        var queue = PoolDictionary[identifier];

        if(queue.Count < amount)//need to pool more
        {
            var toPool = Math.Max(amount-queue.Count, loadAmount);
            var success = GenerateNewObjects(identifier, toPool, loaderOverride);
            if(!success) return result;
        }

        //should've generated new objects as needed
        
        if(queue.Count < amount)//so this shouldn't happen in this scenerio
        {
            throw new Exception($"Projectile pool of type {typeof(T).Name} generated new objects for identifier {identifier}, but upon coming to fetch them, found an insufficient amount of objects. This is a logic error and shouldn't happen. If it does, FUCK YOU.");
        }

        for(int i = 0; i < queue.Count; ++i) result.Add(queue.Dequeue());

        return result;
    }

    public bool GenerateNewObjects(string identifier, int amount, PackedScene loaderOverride = null)
    {
        if(amount == 0) return true;//nothing to pool
        PackedScene loader;
        if(loaderOverride is null)
        {
            if(!DefaultLoaders.TryGetValue(identifier, out loader))
            {
                GD.PushError($"Cannot generate new object of type {typeof(T).Name} with identifier {identifier} because it does not have a default loader defined and no loader override is given");
                return false;
            }
        }
        else loader = loaderOverride;

        PoolDictionary.TryAdd(identifier, new Queue<T>());
        var queue = PoolDictionary[identifier];

        for(int i = 0; i < amount; ++i)
            queue.Enqueue(loader.Instance<T>());

        return true;
    }
}
