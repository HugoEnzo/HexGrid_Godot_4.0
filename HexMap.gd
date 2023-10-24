@tool
extends Node

# var state = null : set = _set_state, get = _get_state
# Private properties
var _hex_grid:Dictionary = {} 
var _orientation = layout_pointy 
var _size : Vector2 = Vector2(10, 10):
	get= get_size, set = set_size

var _origin:Vector2 = Vector2(0, 0) 

# Public properties
var is_flat : bool:
	get = get_orientation, set = set_orientation

var size:
	get= get_size, set = set_size

var origin:
	get=get_origin, set=set_origin

func get_size():
	return _size
func set_size(value):
	_size = value
# Setters/Getters
func set_orientation(is_flat):
	if is_flat:
		_orientation = layout_flat
	else:
		_orientation = layout_pointy
func get_orientation(): 
	if _orientation == layout_flat:
		return true
	else:
		return false

func vec_2_to_string(vec2:Vector2)-> String:
	return("(%.1f,%.1f)"%[vec2.x,vec2.y])


func set_origin(origin): _origin = origin
func get_origin(): return _origin

# Property descriptor for the editor
func _get_property_list():
	return [
		{usage = PROPERTY_USAGE_CATEGORY, type = TYPE_NIL, name = "HexMap"},
		{type = TYPE_BOOL, name = "is_flat"},
		{type = TYPE_VECTOR2, name = "size"},
		{type = TYPE_VECTOR2, name = "origin"},
	]

# Initialise node, once we're ready

# An inner struct to represent a hex data + wall data
class HexData:
	var data
	var walls

# Layout Constants for verticies.
const layout_pointy = [sqrt(3.0), sqrt(3.0) / 2.0, 0.0, 3.0 / 2.0,
					   sqrt(3.0) / 3.0, -1.0 / 3.0, 0.0, 2.0 / 3.0,
					   0.5]
const layout_flat = [3.0 / 2.0, 0.0, sqrt(3.0) / 2.0, sqrt(3.0),
					 2.0 / 3.0, 0.0, -1.0 / 3.0, sqrt(3.0) / 3.0,
					 0.0]

func _enter_tree():
	# Initialization of the plugin goes here
	pass

func _exit_tree():
	# Clean-up of the plugin goes here
	pass

func ready():
	_hex_grid = {}

# Add and removal w/ HexData wrapper
func add_hex(hex, data):
	if (_hex_grid.has(hex)):
		return
	var hd = HexData.new()
	hd.data = data
	hd.walls = []
	for i in range(5):
		hd.walls.push_back(null)
	_hex_grid[hex] = hd

func move_hex(hex_old, hex_new):
	if (_hex_grid.has(hex_new) || !_hex_grid.has(hex_old)):
		return
	_hex_grid[hex_new] = _hex_grid[hex_old]
	_hex_grid.erase(hex_old)

func remove_hex(hex):
	if (_hex_grid.has(hex)):
		_hex_grid.erase(hex)

func get_hex(hex):
	if (_hex_grid.has(hex)):
		return _hex_grid[hex].data

func get_all_hex():
	var hex_list = {}
	for coord in _hex_grid.keys():
		hex_list[coord] = _hex_grid[coord].data
	return hex_list

func get_wall(hex, direction):
	if (_hex_grid.has(hex)):
		return _hex_grid[hex].walls[direction]

# Rotation Transforms
func rotate_hex_left(hex):
	return Vector3(-hex.z, -hex.x, -hex.y);
func rotate_hex_right(hex):
	return Vector3(-hex.y, -hex.z, -hex.x);

# Pixel func and things useful to drawing.
func hex_to_pixel(hex) -> Vector2:
	var x = (_orientation[0] * hex.x + _orientation[1] * hex.y) * _size.x
	var y = (_orientation[2] * hex.x + _orientation[3] * hex.y) * _size.y
	return Vector2(x + _origin.x, y + _origin.y);

func pixel_to_hex(pos):
	var pt = Vector2((pos.x - _origin.x) / _size.x,
				   (pos.y - _origin.y) / _size.y);
	print("Relative pos %s " % vec_2_to_string(pt))
	var q = _orientation[4] * pt.x + _orientation[5] * pt.y;
	var r = _orientation[6] * pt.x + _orientation[7] * pt.y;
	return round_hex(Vector3(q, r, -q - r))

func round_hex(hex):
	var rx = round(hex.x)
	var ry = round(hex.y)
	var rz = round(hex.z)

	var x_diff = abs(rx - hex.x)
	var y_diff = abs(ry - hex.y)
	var z_diff = abs(rz - hex.z)

	if x_diff > y_diff and x_diff > z_diff:
		rx = -ry-rz
	elif y_diff > z_diff:
		ry = -rx-rz
	else:
		rz = -rx-ry

	return Vector3(rx, ry, rz)
func hex_corner_offset(corner):
	var angle = 2.0 * PI * (_orientation[8] + corner) / 6;
	return Vector2(_size.x * cos(angle), _size.y * sin(angle));

func hex_corners(hex):
	var corners = [];
	var center = hex_to_pixel(hex);
	for i in range(7):
		var offset = hex_corner_offset(i);
		corners.push_back(Vector2(center.x + offset.x,
								center.y + offset.y));
	return corners

# Dicts of relative cube coordinates for directionals.
const hex_directions = [
	Vector3( 1, -1,  0), Vector3( 1,  0, -1), Vector3( 0,  1, -1),
	Vector3(-1,  1,  0), Vector3(-1,  0,  1), Vector3( 0, -1,  1)
]
const hex_diagonals = [
	Vector3( 2, -1, -1), Vector3( 1,  1, -2), Vector3(-1,  2, -1), 
	Vector3(-2,  1,  1), Vector3(-1, -1,  2), Vector3( 1, -2,  1)
]

# Return the coordinates of a direction from a given hex
func neighbor_hex(hex, direction):
	return hex + hex_directions[direction]


func diagonal_neighbor_hex(hex, direction):
	return hex + hex_diagonals[direction]

# Distance and from origin hex lengths.
func hex_length(hex):
	return (abs(hex.x) + abs(hex.y) + abs(hex.z)) / 2;

func hex_distance(hex_a, hex_b):
	return hex_length(hex_a - hex_b);
