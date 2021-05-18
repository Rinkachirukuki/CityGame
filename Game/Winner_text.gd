extends Label

sync func return_to_lobby():
	get_tree().change_scene("res://Network/Network_setup.tscn")

func _ready():
	pass # Replace with function body.


func _on_Win_Timer_timeout():
	if get_tree().has_network_peer():
		if get_tree().is_network_server():
			rpc("return_to_lobby")

