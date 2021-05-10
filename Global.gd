extends Node

func instance_node_at_location(node: Object,parent: Object,location: Vector2) -> Object:
	var node_instance = instance_node(node,parent)
	node_instance.global_position = location
	return node_instance
	
	

func instance_node(node: Object,parent: Object) -> Object:
	var node_instance = node.instance()
	parent.add_child(node_instance)
	return node_instance

var player2id = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
