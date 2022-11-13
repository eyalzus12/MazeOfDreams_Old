using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public class BodySeperationTest2 : Node2D
{
    //amount of rooms to load
    const int ROOM_AMOUNT = 300;
    //radius of circle to spawn rooms in
    const int SPAWN_RADIUS = 100;
    //chance to reconnect rooms
    const float EXTRA_CON_CHANCE = 0.1f;
    //penalty for going near corners
    const float DISCOURGE_PENALTY = 3f;

    //tiles you can't pass through when connecting
    static readonly HashSet<string> NON_PASSABLE = new HashSet<string>{"wall","corner","door", "possible_door"};

    //list of rooms you could load
    static readonly string[] TEST_ROOMS = {"res://Scenes/Rooms/MainRoomTest.tscn", "res://Scenes/Rooms/MainRoomTest2.tscn", "res://Scenes/Rooms/MainRoomTest3.tscn"};

    private RandomNumberGenerator RNG;

    public List<GameRoom> Rooms{get; set;} = new List<GameRoom>();
    public TileMap Tiles{get; set;}
    public RoomSpreader Spreader{get; set;}

    public BodySeperationTest2() {}

    public override void _Ready()
    {
        //get the RNG
        RNG = GetTree().Root.GetNode<Randomizer>(nameof(Randomizer)).RNG;
        //get the tilemap
        Tiles = GetNodeOrNull<TileMap>("TileMap");
        if(Tiles.TileSet is null) Tiles.TileSet = new TileSet();

        //get room loaders
        var rooms = TEST_ROOMS.Select(r => ResourceLoader.Load<PackedScene>(r)).ToList();

        //create the shape and room list
        var shapes = new List<Shape2D>();
        for(int i = 0; i < ROOM_AMOUNT; ++i)
        {
            //choose random room type
            var newRoomType = RNG.Choice(rooms);
            //create room
            var newRoom = newRoomType.Instance<GameRoom>();
            //add data to lists
            Rooms.Add(newRoom);
            shapes.Add(newRoom.BoundingShape);
        }

        //create the room spreader with the shape list
        Spreader = new RoomSpreader(Tiles.CellSize, SPAWN_RADIUS, shapes);
        //run OnSpreadFinished when the spreading is finished
        Spreader.Connect(nameof(RoomSpreader.SpreadingFinished), this, nameof(OnSpreadFinished));
        //add to the scene
        AddChild(Spreader);
    }

    public void OnSpreadFinished(List<Vector2> positions)
    {
        //stores the instance IDs of tilesets we load
        var tileSetSet = new HashSet<ulong>();
        //stores dictionaries to convert old tile IDs to new tile IDs
        var idDictDict = new Dictionary<ulong, Dictionary<int, int>>();
        //stores the room bounds
        var roomBounds = new List<List<Vector2>>(new List<Vector2>[Rooms.Count]);

        for(int i = 0; i < Rooms.Count; ++i)
        {
            roomBounds[i] = new List<Vector2>();
            var room = Rooms[i];
            //put room in its position
            room.Position = positions[i];
            //add room to scene
            AddChild(room);

            var tileMap = room.Tiles;

            //we now merge the tilesets
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
                //get tile ID
                var idx = tileMap.GetCellv(c);
                //get new tile ID
                var newTileID = idDictDict[tileMap.TileSet.GetInstanceId()][idx];
                //get tile position in our tilemap
                var worldPos = tileMap.ToGlobal(tileMap.MapToWorld(c));
                var selfPos = Tiles.WorldToMap(Tiles.ToLocal(worldPos));
                //add to bounds list if wall
                if(tileMap.TileSet.TileGetName(idx) == "possible_door") roomBounds[i].Add(selfPos);
                //place tile
                Tiles.SetCellv(selfPos,newTileID);
            }

            //remove room's original tilemap
            tileMap.QueueFree();
        }

        
        var connections =
            //create room connection graph from rooms positions
            WeightedGraph.GenerateFromPointList(positions, new HashSet<(int, int)>())
            //create a sub-graph with no loops that has minimum total distance, then readd some edges
            .RandomKruskal(RNG, EXTRA_CON_CHANCE);

        //create bridges
        foreach(var edge in connections.Edges)
        {
            var first = Rooms[edge.First];
            var second = Rooms[edge.Second];
            var bridge = RoomAStar(first, second, roomBounds[edge.First], roomBounds[edge.Second]);

            //connection failed
            if(bridge is null)
            {
                GD.PushError($"Failed to connect rooms {edge.First} and {edge.Second}");
                continue;
            }

            //add bridge
            for(int i = 0; i < bridge.Count; ++i)
            {
                var tileName = (i == 0 || i == bridge.Count-1)?"door":"bridge";
                Tiles.SetCellv(bridge[i],Tiles.TileSet.FindTileByName(tileName));
            }
        }

        var possibleDoorCells = Tiles.GetUsedCells().Typed<Vector2>().Where(v => Tiles.TileSet.TileGetName(Tiles.GetCellv(v)) == "possible_door");
        foreach(var pdc in possibleDoorCells)
            Tiles.SetCellv(pdc, Tiles.TileSet.FindTileByName("wall"));
    }

    private List<Vector2> RoomAStar(GameRoom from, GameRoom to, List<Vector2> fromBounds, List<Vector2> toBounds)
    {
        return GridAStar(fromBounds, toBounds.ToHashSet());
    }

    private static readonly Vector2[] dirs = {Vector2.Up, Vector2.Down, Vector2.Left, Vector2.Right};
    private List<Vector2> GridAStar(List<Vector2> froms, HashSet<Vector2> tos)
    {
        //nothing to connect
        if(froms.Count == 0 || tos.Count == 0) return null;

        //penalty for going near a corner
        float ExtraCornerPenalty(Vector2 v)
        {
            var ID = Tiles.GetCellv(v);
            if(ID == TileMap.InvalidCell) return 0f;
            var tileName = Tiles.TileSet.TileGetName(ID);
            if(tileName == "discourge") return DISCOURGE_PENALTY;
            else return 0f;
        }

        //total penalty - distance to target + going through corners
        float H(Vector2 v) => tos.Min(to => v.GridDistanceTo(to)) + ExtraCornerPenalty(v);

        //the cells that still need to get checked
        var candidates = new PriorityQueue<Vector2, float>();
        var candidates_set = new HashSet<Vector2>();
        //stores the path from each cell
        var pre = new Dictionary<Vector2, Vector2>();
        //distance
        var gscore = new Dictionary<Vector2, float>();
        //distance + penalty
        var fscore = new Dictionary<Vector2, float>();

        //initialize shit
        foreach(var from in froms)
        {
            gscore[from] = 0;
            fscore[from] = H(from);

            candidates.Enqueue(from, 0);
            candidates_set.Add(from);
        }

        var end = Vector2.One * float.PositiveInfinity;

        while(candidates.Count != 0)
        {
            var current = candidates.Dequeue();
            candidates_set.Remove(current);
            if(tos.Contains(current)) {end = current; break;}

            foreach(var d in dirs)
            {
                var neighbor = current+d;
                if(tos.Contains(neighbor))
                {
                    pre[neighbor] = current;
                    end = neighbor;
                    candidates.Clear();
                    break;
                }

                var neighborID = Tiles.GetCellv(neighbor);
                if(neighborID != TileMap.InvalidCell && NON_PASSABLE.Contains(Tiles.TileSet.TileGetName(neighborID))) continue;//occupied

                gscore.TryAdd(neighbor, float.PositiveInfinity);
                fscore.TryAdd(neighbor, float.PositiveInfinity);

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

        if(float.IsPositiveInfinity(end.x)) return null;

        //reconstruct path
        var iter = end;
        var path = Enumerable.Empty<Vector2>().Prepend(iter);
        while(pre.ContainsKey(iter))
        {
            iter = pre[iter];
            path = path.Prepend(iter);
        }

        return path.ToList();
    }
}
