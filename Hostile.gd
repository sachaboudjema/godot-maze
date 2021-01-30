extends Mobile
class_name Hostile

var map: Map
var wait: float
var path = []
var movement: int = 5
var min_wait: float = 1
var max_wait: float = 3


func _ready():
	speed = 4


func _process(delta):
	if !is_moving():
		if path:
			move(path.pop_front())
		else:
			wait -= delta
			if wait <= 0:
				path = rand_path(cellv(), movement)
				wait = rand_range(min_wait, max_wait)


func remove():
	queue_free()


func cellv():
	return map.world_to_map(position)


func rand_path(c: Vector2, d: int, p: Array = []) -> Array:
	if d > 0:
		var ns = map.neighbours(c, 1)
		ns.shuffle()
		for n in ns:
			if map.get_cellv(n) == map.Tile.FLOOR:
				if (!p) || (n - c + p[-1]):
					p.append(n - c)
					return rand_path(n, d - 1, p)
	return p
