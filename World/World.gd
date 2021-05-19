extends YSort

onready var tmap = $CliffTileMap
var tileCollision = load("res://World/TileHitbox.tscn")

func _ready():
	a()

func a():
	
	for pos in tmap.get_used_cells():
		pos *= 32
		
		Global.instance_node_at_location(tileCollision,self,pos)
