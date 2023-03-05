using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public partial class MazeDreamer : Node2D
{
    /*
    [Signal]
    public delegate void DreamingFinished(GameRoom spawn);

    [Export]
    public int RoomAmount = 300;
    [Export]
    public int SpawnRadius = 100;
    [Export]
    public float ExtraConnectionChance = 0.3f;
    [Export]
    public float ExtraConnectionCurveMultiplier = 0.01f;
    [Export]
    public float DiscourgePenalty = 4f;
    [Export]
    public Godot.Collections.Array<PackedScene> Rooms;
    [Export]
    public PackedScene SpawnRoom;
    [Export]
    public TileSet BridgeTileSet;
    [Export]
    public string BridgeTile = "bridge";
    [Export]
    public string BridgeEdgeTile = "bridge edge";

    private RandomNumberGenerator RNG;

    public List<GameRoom> LoadedRooms{get; set;} = new List<GameRoom>();
    public TileMap Tiles{get; set;}
    private RoomSpreader _spreader;

    //a by-room set of tile ids you can't pass when building a bridge
    private Dictionary<int, HashSet<int>> _noBridgePass = new Dictionary<int, HashSet<int>>();
    //a by-room set of tile ids that you're discourged to be near
    private Dictionary<int, HashSet<int>> _discourgeNear = new Dictionary<int, HashSet<int>>();
    //a by-room dictionary of tile ids that indicates what should be changed after bridges are connected
    private Dictionary<int, Dictionary<int, int>> _postBridgesReplacements = new Dictionary<int, Dictionary<int, int>>();
    //a by-room dictionary of tile ids that indicates what can be connected to with a bridge and what to change it to
    private Dictionary<int, Dictionary<int, int>> _bridgeConnections = new Dictionary<int, Dictionary<int, int>>();
    private Dictionary<int, Dictionary<int, PackedScene>> _bridgeScenes = new Dictionary<int, Dictionary<int, PackedScene>>();
    //a dictionary that matches tile position to room index
    private Dictionary<Vector2, int> _roomTileDict = new Dictionary<Vector2, int>();
    private List<List<Vector2>> _roomBounds;
    private List<int> _generationIndexList = new List<int>();
    //stores the instance IDs of tilesets we load
    private HashSet<ulong> _tileSetSet = new HashSet<ulong>();
    //stores dictionaries to convert old tile IDs to new tile IDs
    private Dictionary<ulong, Dictionary<int, int>> _idDictDict = new Dictionary<ulong, Dictionary<int, int>>();

    private int _bridgeTileID;
    private int _bridgeEdgeTileID;

    private GameRoom _spawnRoom;

    public MazeDreamer() {}

    public override void _Ready()
    {
        //get the RNG
        RNG = GetTree().Root.GetNodeOrNull<Randomizer>(nameof(Randomizer))?.RNG;
        if(RNG is null)
        {
            GD.PushError($"Cannot generate floor {Name} as the RNG is non-existent or null");
            return;
        }
        //get the tilemap
        Tiles = GetNodeOrNull<TileMap>("NavRegion/" + nameof(Tiles));
        //Tiles.SetProcess(false);
        Tiles.TileSet = BridgeTileSet;

        _bridgeTileID = Tiles.TileSet.FindTileByName(BridgeTile);
        _bridgeEdgeTileID = Tiles.TileSet.FindTileByName(BridgeEdgeTile);

        //create the shape and room list
        var shapes = new List<List<(Transform2D, Shape2D)>>();

        _spawnRoom = SpawnRoom.Instance<GameRoom>();
        _spawnRoom.RoomIndex = 0;
        LoadedRooms.Add(_spawnRoom);
        AddChild(_spawnRoom);
        shapes.Add(_spawnRoom.BoundShapes);
        RemoveChild(_spawnRoom);
        
        for(int i = 0; i < RoomAmount; ++i)
        {
            //choose random room type
            var newRoomType = RNG.Choice(Rooms);
            //create room
            var newRoom = newRoomType.Instance<GameRoom>();
            //set room index
            newRoom.RoomIndex = i+1;
            //add data to lists
            LoadedRooms.Add(newRoom);
            AddChild(newRoom);
            shapes.Add(newRoom.BoundShapes);
            RemoveChild(newRoom);
        }

        //create the room spreader with the shape list
        _spreader = new RoomSpreader(Tiles.CellSize, SpawnRadius, shapes);
        //run OnSpreadFinished when the spreading is finished
        _spreader.Connect(nameof(RoomSpreader.SpreadingFinished),new Callable(this,nameof(OnSpreadFinished)));
        //add to the scene
        AddChild(_spreader);
    }

    public void OnSpreadFinished(List<Vector2> positions)
    {
        _spreader.QueueFree();

        //stores the room bounds
        
        _roomBounds = new List<List<Vector2>>(new List<Vector2>[LoadedRooms.Count]);
        
        var mainPositions = new List<Vector2>();
        for(int i = 0; i < LoadedRooms.Count; ++i)
        {
            var room = LoadedRooms[i];
            //put room in its position
            room.Position = positions[i];
            //add room if main
            if(room.Type == GameRoom.RoomType.Main)
            {
                mainPositions.Add(room.Position);
                AddRoom(room);
            }
            //add room tiles to dict
            AddRoomTiles(room);
        }
        
        var connections =
            //create room connection graph from rooms positions
            WeightedGraph.GenerateFromPointList(mainPositions, new HashSet<(int, int)>())
            //create a sub-graph with no loops that has minimum total distance, then readd some edges
            .RandomKruskal(RNG, ExtraConnectionChance, ExtraConnectionCurveMultiplier);
        
        //create bridges
        for(int i = 0; i < connections.Edges.Count; ++i)
        {
            var edge = connections.Edges[i];
            var edgeFirst = _generationIndexList[edge.First];
            var edgeSecond = _generationIndexList[edge.Second];

            var bridge = RoomAStar(connections, _roomBounds[edgeFirst], _roomBounds[edgeSecond], edge.First, edge.Second);

            //connection failed
            if(bridge is null)
            {
                GD.PushError($"Failed to connect rooms {edgeFirst} and {edgeSecond}");
                continue;
            }

            //add bridge
            for(int j = 0; j < bridge.Count; ++j)
            {
                (Vector2 pos, BridgeType type) = bridge[j];
                var ID = Tiles.GetCellv(pos);
                switch(type)
                {
                    case BridgeType.Start:
                        _bridgeConnections[edgeFirst].TryInvokeValue(ID, d => Tiles.SetCellv(pos,d));
                        _bridgeScenes[edgeFirst].TryInvokeValue(ID, p => 
                        {
                            var n = p.Instance<Node2D>();
                            LoadedRooms[edgeFirst].AddChild(n);
                            n.GlobalPosition = Tiles.ToGlobal(Tiles.MapToWorld(pos) + Tiles.CellSize/2f);
                        });
                        break;
                    case BridgeType.End:
                        _bridgeConnections[edgeSecond].TryInvokeValue(ID, d => Tiles.SetCellv(pos,d));
                        _bridgeScenes[edgeSecond].TryInvokeValue(ID, p => 
                        {
                            var n = p.Instance<Node2D>();
                            LoadedRooms[edgeSecond].AddChild(n);
                            n.GlobalPosition = Tiles.ToGlobal(Tiles.MapToWorld(pos) + Tiles.CellSize/2f);
                        });
                        break;
                    case BridgeType.Edge:
                        if(ID == TileMap.InvalidCell)
                            Tiles.SetCellv(pos, _bridgeEdgeTileID);
                        break;
                    case BridgeType.Bridge:
                        if(ID == TileMap.InvalidCell || ID == _bridgeEdgeTileID)
                            Tiles.SetCellv(pos, _bridgeTileID);
                        break;
                    default:
                        GD.PushError($"Unknown bridge part type {type}");
                        break;
                }
            }
        }

        //for each cell
        Tiles.GetUsedCells().OfType<Vector2>().ForEach(   
        cell =>
            //if they belong to a room
            _roomTileDict.TryInvokeValue(cell,
            roomIndex =>
                //and if the cell has a replacement
                _postBridgesReplacements[roomIndex].TryInvokeValue(Tiles.GetCellv(cell),
                replacement =>
                    //replace them
                    Tiles.SetCellv(cell, replacement)   
                )
            )
        );

        //dispose of the unused rooms, as they're no longer needed, plus the bound shapes
        for(int i = 0; i < LoadedRooms.Count; ++i)
        {
            var room = LoadedRooms[i];
            if(!room.GenerationUsed) room.QueueFree();
            else
            {
                room.OnDreamingFinished();
                room.GetNode(nameof(room.BoundShapes)).QueueFree();
            }
        }

        GD.Print("Finished dreaming");

        //emit ended
        EmitSignal(nameof(DreamingFinished), _spawnRoom);
    }

    public void AddRoomTiles(GameRoom room)
    {
        var alreadyIn = room.IsInsideTree();
        
        if(!alreadyIn) AddChild(room);

        room.Tiles
            .GetUsedCells().OfType<Vector2>() //get used cells
            .Select(c => room.Tiles.MapToMap(Tiles, c)) //transfer to new tilemap
            .ForEach(c => _roomTileDict[c] = room.RoomIndex); //add to dict
        
        if(!alreadyIn) RemoveChild(room);
    }

    public void AddRoom(GameRoom room)
    {
        //already added
        if(room.GenerationUsed) return;

        //add to scene
        AddChild(room);

        _roomBounds[room.RoomIndex] = new List<Vector2>();

        //mark as used in generation
        room.GenerationUsed = true;
        //set index
        room.GenerationIndex = _generationIndexList.Count;
        //add to generation->original index list
        _generationIndexList.Add(room.RoomIndex);
        var tileMap = room.Tiles;

        //add tiles to the floor
        PlaceTilemap(tileMap);
        
        var _idDict = _idDictDict[room.Tiles.TileSet.GetInstanceId()];
        
        _postBridgesReplacements[room.RoomIndex] = new Dictionary<int, int>();
        foreach((string key, string value) in room.PostBridgeReplacements)
            _postBridgesReplacements[room.RoomIndex][_idDict[tileMap.TileSet.FindTileByName(key)]] = _idDict[tileMap.TileSet.FindTileByName(value)];
        
        _bridgeConnections[room.RoomIndex] = new Dictionary<int, int>();
        foreach((string key, string value) in room.BridgeConnectionReplacements)
            _bridgeConnections[room.RoomIndex][_idDict[tileMap.TileSet.FindTileByName(key)]] = _idDict[tileMap.TileSet.FindTileByName(value)];
        
        _bridgeScenes[room.RoomIndex] = new Dictionary<int, PackedScene>();
        foreach((string key, PackedScene value) in room.BridgeConnectionScenes)
            _bridgeScenes[room.RoomIndex][_idDict[tileMap.TileSet.FindTileByName(key)]] = value;

        _noBridgePass[room.RoomIndex] = new HashSet<int>(room.BridgePassBlockers.Select(bpb => _idDict[tileMap.TileSet.FindTileByName(bpb)]));
        _discourgeNear[room.RoomIndex] = new HashSet<int>(room.DiscourgeNear.Select(bpb => _idDict[tileMap.TileSet.FindTileByName(bpb)]));

        foreach(Vector2 c in tileMap.GetUsedCells())
        {
            var id = _idDict[tileMap.GetCellv(c)];
            if(_bridgeConnections[room.RoomIndex].ContainsKey(id) || _bridgeScenes[room.RoomIndex].ContainsKey(id))
                _roomBounds[room.RoomIndex].Add(tileMap.MapToMap(Tiles, c));
        }
        
        //remove room's original tilemap
        tileMap.QueueFree();
    }

    public void PlaceTilemap(TileMap tileMap)
    {
        var instanceId = tileMap.TileSet.GetInstanceId();
        //merge the tilesets
        if(!_tileSetSet.Contains(instanceId))
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

            _idDictDict.Add(instanceId, idDict);
            _tileSetSet.Add(instanceId);
        }

        //place tiles
        foreach(Vector2 c in tileMap.GetUsedCells())
        {
            //get tile ID
            var idx = tileMap.GetCellv(c);
            //get new tile ID
            var newTileID = _idDictDict[instanceId][idx];
            //place tile
            Tiles.SetCellv(tileMap.MapToMap(Tiles, c),newTileID);
        }
    }

    private List<(Vector2,BridgeType)> RoomAStar(WeightedGraph connections, List<Vector2> fromBounds, List<Vector2> toBounds, int fromIdx, int toIdx)
    {
        return GridAStar(connections, fromBounds, toBounds.ToHashSet(), fromIdx, toIdx);
    }

    private enum BridgeType{Start, End, Edge, Bridge};
    private static readonly Vector2[] DIRS = {Vector2.Up, Vector2.Down, Vector2.Left, Vector2.Right};
    private List<(Vector2,BridgeType)> GridAStar(WeightedGraph connections, List<Vector2> froms, HashSet<Vector2> tos, int fromIdx, int toIdx)
    {
        //nothing to connect
        if(froms.Count == 0 || tos.Count == 0) return null;

        //penalty for going near a corner
        float HDiscourge(Vector2 v) => DIRS.Any(d =>
        {
            var neighbor = v+d;
            var nid = Tiles.GetCellv(neighbor);
            if(nid == TileMap.InvalidCell || !_roomTileDict.ContainsKey(neighbor)) return false;

            var nindex = _roomTileDict[neighbor];
            var neighborRoom = LoadedRooms[nindex];
            if(!neighborRoom.GenerationUsed) return false;

            return _discourgeNear[nindex].Contains(nid);
        })?DiscourgePenalty:0f;

        //total penalty - distance to target + going through corners
        float H(Vector2 v) => tos.Contains(v)?float.NegativeInfinity:(tos.Min(to => v.GridDistanceTo(to)) + HDiscourge(v));

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

        var end = Vector2.Inf;

        while(candidates.Count != 0)
        {
            var current = candidates.Dequeue();
            candidates_set.Remove(current);
            if(tos.Contains(current)) {end = current; break;}

            foreach(var d in DIRS)
            {
                var neighbor = current+d;

                var neighborID = Tiles.GetCellv(neighbor);

                //found an empty cell
                if(neighborID == TileMap.InvalidCell && _roomTileDict.ContainsKey(neighbor))
                {
                    var roomIdx = _roomTileDict[neighbor];
                    var roomRoom = LoadedRooms[roomIdx];
                    //belonging to a side room
                    if(LoadedRooms[roomIdx].Type == GameRoom.RoomType.Side)
                    {
                        AddRoom(roomRoom);
                        var roomGenIdx = roomRoom.GenerationIndex;
                        //that is valid to connect to
                        if(roomGenIdx != fromIdx && roomGenIdx != toIdx)
                        {
                            connections.Edges.Add(new WeightedGraphEdge(fromIdx, roomGenIdx, 0));
                            connections.Edges.Add(new WeightedGraphEdge(roomGenIdx, toIdx, 0));
                            return new List<(Vector2,BridgeType)>();
                        }
                    }
                }

                if(
                    !tos.Contains(neighbor) && //not a target
                    neighborID != TileMap.InvalidCell && //not empty
                    _roomTileDict.ContainsKey(neighbor) && //belongs to a room
                    _noBridgePass[_roomTileDict[neighbor]].Contains(neighborID) //is a pathing preventer
                ) continue;

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

        if(Mathf.IsInf(end.x)) return null;

        //reconstruct path
        var iter = end;
        var path = new List<(Vector2,BridgeType)>{(iter,BridgeType.End)};
        iter = pre[iter];
        while(pre.ContainsKey(iter))
        {
            path.AddRange(new (Vector2,BridgeType)[]
            {
                (iter+Vector2.Up,BridgeType.Edge),
                (iter+Vector2.Down,BridgeType.Edge),
                (iter+Vector2.Right,BridgeType.Edge),
                (iter+Vector2.Left,BridgeType.Edge),
                (iter,BridgeType.Bridge)
            });

            iter = pre[iter];
        }

        path.Add((iter,BridgeType.Start));

        return path;
    }*/
}
