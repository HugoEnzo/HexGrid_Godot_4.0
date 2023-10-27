# HexGrid_Godot_4.0
<u>HexGrid library with functions based on www.redblobgames.com 's implementation:</u>

Godot asset store link: https://godotengine.org/asset-library/asset/2292

 - Make an addons folder on your project's (res://) folder and then move HexMap folder to the addons folder
 - Navigate to your project settings -> plugins -> and then add the plugin to your project

<u>Public variables and methods:</u>


Variable - 

  var is_flat: Determines drawing style of flat or pointy topped hex

  var size: A Vector2 of given hex size. x doesnt not have to equal y

  var origin: The x/y position of the origin of the grid


Functions- 

  func add_hex(hex, data): Add new data to an unoccupied hex.

  func move_hex(hex_old, hex_new): Move occupied hex to unoccupied location.

  func remove_hex(hex): Remove an occupied hex

  func get_hex(hex): Get data for a hex

  func get_all_hex(): Get a dict of all hex data

  func get_wall(hex, direction): Get wall data for a given hex

<u>Rotation Transform Herlpers:</u>

  func rotate_hex_left(hex):

  func rotate_hex_right(hex):



<u>Pixel funcs and things useful to drawing.</u>



  func hex_to_pixel(hex): x,y for a given hex.

  func pixel_to_hex(pos): Full hex for a given x,y

  func round_hex(hex): Round fractional hex to full.

  func hex_corner_offset(corner): Vector2 Offset for a given corner based on layout

  func hex_corners(hex): Array of Vector2 locations to draw a full hex.


<u>Neighbor and Distance Utility Functions</u>



  func neighbor_hex(hex, direction):

  func diagonal_neighbor_hex(hex, direction):

  func hex_length(hex):

  func hex_distance(hex_a, hex_b):
```

   
