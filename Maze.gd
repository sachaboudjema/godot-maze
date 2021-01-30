extends Node2D

const MAX_LEVEL = 13
const Hostile = preload("res://Hostile.tscn")

enum EndLevel {EXIT, DEAD}
enum AcceptAction {NONE, START, USE}


var level = 0
var global_timer = 0
var playing = false
var accept_action = AcceptAction.NONE


func _ready():
	$Map.rng.randomize()
	new_level()


func _process(delta):
	if playing:
		global_timer += delta
		if !$Player.is_moving():
			var dir = Vector2.ZERO
			if Input.is_action_pressed("ui_up"):
				dir = Vector2.UP
			if Input.is_action_pressed("ui_down"):
				dir = Vector2.DOWN
			if Input.is_action_pressed("ui_left"):
				dir = Vector2.LEFT
			if Input.is_action_pressed("ui_right"):
				dir = Vector2.RIGHT
			if dir && $Map.get_cellv($Map.world_to_map($Player.position) + dir) != $Map.Tile.WALL:
				$Player.move(dir)


func _input(event):
	if event.is_action_pressed("ui_accept"):
		match accept_action:
			AcceptAction.START: start_level()


func init_map():
	$Map.initialize(level)
	$Camera.position = $Map.size * $Map.cell_size / 2


func new_level():
	$TransitionScreen.show(level, global_timer)
	init_map()
	$TransitionScreen.continue_()
	accept_action = AcceptAction.START


func start_level():
	spawn_hostiles()
	$Player.position = $Map.map_to_world($Map.start_cellv)
	$TransitionScreen.hide()
	accept_action = AcceptAction.USE
	playing = true


func end_level(reason):
	playing = false
	accept_action = AcceptAction.NONE
	get_tree().call_group("hostiles", "remove")
	match reason:
		EndLevel.EXIT:
			if level == MAX_LEVEL:
				end_game()
			level += 1
		EndLevel.DEAD:
			pass
			#start_level()
	new_level()

func end_game():
	pass


func spawn_hostiles():
	var tiles = $Map.get_used_cells_by_id($Map.Tile.FLOOR)
	tiles.shuffle()
	var h = Hostile.instance()
	h.position = $Map.map_to_world(tiles.pop_back())
	h.map = $Map
	add_child(h)


func _on_Player_area_entered(area):
	if area.is_in_group("hostiles"):
		end_level(EndLevel.DEAD)


func _on_Player_body_entered(body):
	if body.get_name() == "Map":
		var cellv = $Map.world_to_map($Player.position)
		
		if $Map.get_cellv(cellv) == $Map.Tile.EXIT:
			end_level(EndLevel.EXIT)
