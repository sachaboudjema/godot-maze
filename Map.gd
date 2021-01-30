extends TileMap
class_name Map

const MIN_SIZE = Vector2(15, 7)
const SECT = 2

enum Tile {FLOOR, WALL, EXIT}

var size
var exit_cellv = Vector2.ONE
var start_cellv = Vector2(int(MIN_SIZE.x / 2), MIN_SIZE.y - 2)
var floor_sectors
var rng = RandomNumberGenerator.new()


func _ready():
	pass


func initialize(level):
	size = MIN_SIZE + Vector2.ONE * level * 2
	if level > 0:
		exit_cellv = opposit_corner(exit_cellv)
		start_cellv = opposit_corner(start_cellv)
	reset()
	set_cellv(exit_cellv, Tile.EXIT)
	generate_floors()
	floor_sectors = get_sectors(SECT, Tile.FLOOR)


func opposit_corner(corner: Vector2):
	if corner == Vector2.ONE:
		return size - Vector2(2,2)
	return Vector2.ONE


func reset():
	clear()
	for x in range(size.x):
		for y in range(size.y):
			set_cell(x, y, Tile.WALL)


func generate_floors():
	var c; var d; var w; var n;
	var stack = []
	stack.push_back(exit_cellv)
	while stack:
		c = stack.pop_back()
		n = unvisited_neighbours(c)
		if n:
			stack.push_back(c)
			d = n[rng.randi_range(0, len(n)-1)]
			w = c + (d - c)/2
			set_cellv(w, Tile.FLOOR)
			set_cellv(d, Tile.FLOOR)
			stack.push_back(d)


func in_bounds(c: Vector2):
	return c.x > 0  && c.y > 0 && c.x < size.x - 1 && c.y < size.y - 1


func neighbours(cellv: Vector2, d: int):
	var n = []
	if in_bounds(cellv + Vector2(d, 0)):
		n.append(cellv + Vector2(d, 0))
	if in_bounds(cellv + Vector2(-d, 0)):
		n.append(cellv + Vector2(-d, 0))
	if in_bounds(cellv + Vector2(0, d)):
		n.append(cellv + Vector2(0, d))
	if in_bounds(cellv + Vector2(0, -d)):
		n.append(cellv + Vector2(0, -d))
	return n


func unvisited_neighbours(cellv: Vector2):
	var n = []
	for c in neighbours(cellv, 2):
		if get_cellv(c) == Tile.WALL:
			n.append(c)
	return n


func get_sectors(n: int, id: int = Tile.FLOOR):
	var sectors = []
	var sect_size = (size / n).round()
	for _i in range(n*n):
		sectors.append([])
	for c in get_used_cells_by_id(id):
		var i_x = int(c.x / sect_size.x)
		var i_y = int(c.y / sect_size.y)
		sectors[i_x + n*i_y].append(c)
	return sectors


func is_straight(cellv: Vector2):
	var nf = []
	for n in neighbours(cellv, 1):
		if get_cellv(n) == Tile.Floor:
			nf.append(n)
	if (len(nf) == 2) and (nf[0] + nf[1] == Vector2.ZERO):
		return true
	return false


func get_floor_edges(origin: Vector2 = Vector2.ONE, upstream: Vector2 = Vector2.ZERO):
	var edges = []
	var search_dir = []
	for n in neighbours(origin, 1):
		if get_cellv(n) == Tile.FLOOR && (n - upstream != Vector2.ZERO):
			search_dir.append(n - origin)
	for sd in search_dir:
		var next = origin + sd
		while is_straight(next):
			next += sd
		edges.append([origin, next])
		edges.append_array(get_floor_edges(next, sd))
	return edges
