using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public class BodySeperationTest2 : Node2D
{
    const int TILE_SIZE = 32;
    const int ROOM_AMOUNT = 100;
    const int SPAWN_RADIUS = 300;
    const float EXTRA_CON_CHANCE = 0.1f;
    const int MAX_TILE_SEARCH = 50;
    const int BRIDGE_TILE_ID = 2;
    const int BLOCK_TILE_ID = 1;
    const float H_DEVIATION = 2f;

    const string TEST_ROOM = "res://Scenes/Rooms/MainRoomTest.tscn";

    private RandomNumberGenerator RNG;

    public List<GameRoom> Rooms{get; set;} = new List<GameRoom>();
    public TileMap Tiles{get; set;}
    public RoomSpreader Spreader{get; set;}

    public BodySeperationTest2() {}

    public override void _Ready()
    {
        RNG = GetTree().Root.GetNode<Randomizer>(nameof(Randomizer)).RNG;
        Tiles = GetNodeOrNull<TileMap>("TileMap");
        if(Tiles.TileSet is null) Tiles.TileSet = new TileSet();

        var room = ResourceLoader.Load<PackedScene>(TEST_ROOM);

        var shapes = new List<Shape2D>();

        for(int i = 0; i < ROOM_AMOUNT; ++i)
        {
            var newRoom = room.Instance<GameRoom>();
            Rooms.Add(newRoom);
            shapes.Add(newRoom.BoundingShape);
        }

        Spreader = new RoomSpreader(TILE_SIZE, SPAWN_RADIUS, shapes);
        Spreader.Connect(nameof(RoomSpreader.SpreadingFinished), this, nameof(OnSpreadFinished));
        AddChild(Spreader);
    }

    public void OnSpreadFinished(List<Vector2> positions)
    {
        var tileSetSet = new HashSet<ulong>();
        var idDictDict = new Dictionary<ulong, Dictionary<int, int>>();
        for(int i = 0; i < Rooms.Count; ++i)
        {
            var room = Rooms[i];
            room.Position = positions[i];
            AddChild(room);
            var tileMap = room.Tiles;
            if(!tileSetSet.Contains(tileMap.TileSet.GetInstanceId()))
            {
                //copy tiles
                var ids = new Godot.Collections.Array<int>(tileMap.TileSet.GetTilesIds());
                var idDict = new Dictionary<int,int>();
                foreach(var idx in ids)
                {
                    //get new ID
                    var newTileID = Tiles.TileSet.GetLastUnusedTileId();
                    idDict.Add(idx,newTileID);
                    //create tile
                    Tiles.TileSet.CreateTile(newTileID);
                    //copy shape
                    for(int j = 0; j < tileMap.TileSet.TileGetShapeCount(idx); ++j)
                    {
                        var shape = tileMap.TileSet.TileGetShape(idx,j);
                        var transform = tileMap.TileSet.TileGetShapeTransform(idx,j);
                        var oneway = tileMap.TileSet.TileGetShapeOneWay(idx,j);
                        Tiles.TileSet.TileAddShape(newTileID, shape, transform, oneway);
                        var shapeOffset = tileMap.TileSet.TileGetShapeOffset(idx, j);
                        Tiles.TileSet.TileSetShapeOffset(newTileID, j, shapeOffset);
                    }

                    //copy texture
                    var texture = tileMap.TileSet.TileGetTexture(idx);
                    Tiles.TileSet.TileSetTexture(newTileID, texture);
                    var textureOffset = tileMap.TileSet.TileGetTextureOffset(idx);
                    Tiles.TileSet.TileSetTextureOffset(newTileID, textureOffset);

                    //copy navigation
                    var navigation = tileMap.TileSet.TileGetNavigationPolygon(idx);
                    Tiles.TileSet.TileSetNavigationPolygon(newTileID, navigation);
                    var navigationOffset = tileMap.TileSet.TileGetNavigationPolygonOffset(idx);
                    Tiles.TileSet.TileSetNavigationPolygonOffset(newTileID, navigationOffset);

                    //copy light
                    var light = tileMap.TileSet.TileGetLightOccluder(idx);
                    Tiles.TileSet.TileSetLightOccluder(newTileID, light);

                    //copy modulate
                    var modulate = tileMap.TileSet.TileGetModulate(idx);
                    Tiles.TileSet.TileSetModulate(newTileID, modulate);

                    //copy z index
                    var zindex = tileMap.TileSet.TileGetZIndex(idx);
                    Tiles.TileSet.TileSetZIndex(newTileID, zindex);

                    //copy region
                    var region = tileMap.TileSet.TileGetRegion(idx);
                    Tiles.TileSet.TileSetRegion(newTileID, region);
                    
                    //copy material
                    var material = tileMap.TileSet.TileGetMaterial(idx);
                    Tiles.TileSet.TileSetMaterial(newTileID, material);

                    //copy normal map
                    var normalMap = tileMap.TileSet.TileGetNormalMap(idx);
                    Tiles.TileSet.TileSetNormalMap(newTileID, normalMap);

                    //copy tile mode
                    var tileMode = tileMap.TileSet.TileGetTileMode(idx);
                    Tiles.TileSet.TileSetTileMode(newTileID, tileMode);

                    //copy name
                    var name = tileMap.TileSet.TileGetName(idx);
                    Tiles.TileSet.TileSetName(newTileID, name);
                }

                idDictDict.Add(tileMap.TileSet.GetInstanceId(), idDict);
                tileSetSet.Add(tileMap.TileSet.GetInstanceId());
            }

            //place tiles
            var cells = new Godot.Collections.Array<Vector2>(tileMap.GetUsedCells());
            foreach(var c in cells)
            {
                //get tile index
                var idx = tileMap.GetCellv(c);
                var newTileID = idDictDict[tileMap.TileSet.GetInstanceId()][idx];
                //get tile position in our tilemap
                var worldPos = tileMap.ToGlobal(tileMap.MapToWorld(c));
                var selfPos = Tiles.WorldToMap(Tiles.ToLocal(worldPos));
                //place tile
                Tiles.SetCellv(selfPos,newTileID);
            }

            tileMap.QueueFree();
        }

        var connections = WeightedGraph.GenerateFromPointList(positions, new HashSet<(int, int)>()).RandomKruskal(RNG, EXTRA_CON_CHANCE);

        foreach(var edge in connections.Edges)
        {
            var first = Rooms[edge.First];
            var second = Rooms[edge.Second];
            var bridge = RoomAStar(first, second);
            if(bridge is null)
            {
                GD.PushError($"Failed to connect rooms {edge.First} and {edge.Second}");
                continue;
            }

            foreach(var pos in bridge)
            {
                Tiles.SetCellv(pos,BRIDGE_TILE_ID);
            }
        }
    }

    private List<Vector2> RoomAStar(GameRoom from, GameRoom to)
    {
        List<Vector2> best = null;
        foreach(var tdoor in to.Doors)
        {
            var fdoorposs = from.Doors.Select(fdoor => Tiles.WorldToMap(Tiles.ToLocal(fdoor.GlobalPosition))).ToList();
            var tdoorpos = Tiles.WorldToMap(Tiles.ToLocal(tdoor.GlobalPosition));
            var result = GridAStar(fdoorposs, tdoorpos);
            if(result != null && (best is null || result.Count < best.Count)) best = result;
        }
        return best;
    }

    private static readonly Vector2[] dirs = {Vector2.Up, Vector2.Down, Vector2.Left, Vector2.Right};
    private List<Vector2> GridAStar(List<Vector2> froms, Vector2 to)
    {
        int H(Vector2 v) => (int)Math.Abs(v.x-to.x+RNG.RandfRange(-H_DEVIATION,H_DEVIATION)) + (int)Math.Abs(v.y-to.y+RNG.RandfRange(-H_DEVIATION,H_DEVIATION));

        var candidates = new PriorityQueue<Vector2, int>();
        var candidates_set = new HashSet<Vector2>();
        var pre = new Dictionary<Vector2, Vector2>();
        var gscore = new Dictionary<Vector2, int>();
        var fscore = new Dictionary<Vector2, int>();

        foreach(var from in froms)
        {
            gscore[from] = 0;
            fscore[from] = H(from);

            candidates.Enqueue(from, 0);
            candidates_set.Add(from);
        }

        while(candidates.Count != 0)
        {
            var current = candidates.Dequeue();
            candidates_set.Remove(current);
            if(gscore[current] > MAX_TILE_SEARCH) return null;//don't move over 50 cells
            if(current == to) break;//reached goal

            foreach(var d in dirs)
            {
                var neighbor = current+d;
                if(neighbor == to)
                {
                    pre[to] = current;
                    candidates.Clear();
                    break;
                }

                if(Tiles.GetCellv(neighbor) == BLOCK_TILE_ID) continue;//occupied
                gscore.TryAdd(neighbor, int.MaxValue);
                fscore.TryAdd(neighbor, int.MaxValue);

                var tent = gscore[current] + 1;
                if(tent < gscore[neighbor])
                {
                    pre[neighbor] = current;
                    gscore[neighbor] = tent;
                    fscore[neighbor] = tent + H(neighbor);
                    if(!candidates_set.Contains(neighbor))
                    {
                        candidates.Enqueue(neighbor, fscore[neighbor]);
                        candidates_set.Add(neighbor);
                    }
                }
            }
        }

        var iter = to;
        var path = Enumerable.Empty<Vector2>().Prepend(iter);
        while(pre.ContainsKey(iter))
        {
            iter = pre[iter];
            path = path.Prepend(iter);
        }

        return path.ToList();
    }
}
