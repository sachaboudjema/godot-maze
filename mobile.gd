extends Node2D
class_name Mobile

const TILE_SIZE = 16

var speed: float # Tiles per second
var delta_acc: float = 1
var src: Vector2
var dst: Vector2


func _ready():
	pass


func _process(delta):
	if is_moving():
		delta_acc = min(1, delta_acc + delta * speed)
		position = src.linear_interpolate(dst, delta_acc)


func move(d: Vector2):
	delta_acc = 0
	src = position
	dst = position + d * TILE_SIZE


func is_moving():
	return delta_acc < 1
