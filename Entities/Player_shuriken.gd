extends Sprite

var velocity = Vector2(1,0)
var player_rotation

export(int) var speed = 400
export(int) var damage = 40

puppet var puppet_position setget puppet_position_set
puppet var puppet_velocity = Vector2(0,0)
puppet var puppet_rotation = 0

onready var initial_position = global_position

var player_owner = 0

func _ready():
	visible = false
	yield(get_tree(), "idle_frame")
	
	if get_tree().has_network_peer():
		if is_network_master():
			velocity = velocity.rotated(player_rotation)
			rotation = player_rotation
			rset("puppet_velocity", velocity)
			rset("puppet_rotation", rotation)
			rset("puppet_position", position)
	
	visible = true

func _process(delta):
	if get_tree().has_network_peer():
		if is_network_master():
			global_position += velocity * speed * delta
		else:
			rotation = puppet_rotation
			global_position += puppet_velocity * speed * delta

sync func destroy() -> void:
	queue_free()

func puppet_position_set(new_value) -> void:
	puppet_position = new_value
	global_position = puppet_position

func _on_Destroy_timer_timeout():
	if get_tree().has_network_peer():
		if get_tree().is_network_server():
			rpc("destroy")
