extends Resource
class_name DisjointSetUnion

var par: Dictionary = {}
var tsize: Dictionary = {}

func make_set(x) -> void:
	if x in par:
		Logger.error(str("attempt to make_set on already existent element",x))
		return
	par[x] = null
	tsize[x] = 1

func find_set(x):
	if not x in par:
		Logger.error(str("attempt to find_set a non existent element",x))
		return null
	if par[x] == null:
		return x
	par[x] = find_set(par[x])
	return par[x]

func union(x,y) -> bool:
	var px = find_set(x)
	var py = find_set(y)
	if px == py:
		return false
	
	if tsize[px] < tsize[py]:
		par[px] = py
		tsize[py] += tsize[px]
		tsize.erase(px)
	else:
		par[py] = px
		tsize[px] += tsize[py]
		tsize.erase(py)
	
	return true
