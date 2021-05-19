extends Control

var player = load("res://Player/Player.tscn")

var current_spawn_location_instance_number = 1
var current_player_for_spawn_location_number = null

onready var multiplayer_config_ui = $Multiplayer_configure
onready var username = $Multiplayer_configure/le_username

onready var device_ip_address = $UI/l_Device_ip_address
onready var start_game = $UI/b_Start_game

var game_instance

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("network_peer_disconnected", self, "_player_disconnected")
	get_tree().connect("connected_to_server", self, "_connected_to_server")
	
	device_ip_address.text = Network.ip_address
	
	if get_tree().network_peer != null:
		multiplayer_config_ui.hide()
		
		for player in Persistent_nodes.get_children():
			if player.is_in_group("Player"):
				for spawn_location in $Spawn_locations.get_children():
					if int(spawn_location.name) == current_spawn_location_instance_number and current_player_for_spawn_location_number != player:
						player.rpc("enable")
						player.rpc("update_position", spawn_location.global_position)
						current_spawn_location_instance_number += 1
						current_player_for_spawn_location_number = player
	else:
		start_game.hide()
	
	game_ready_check()

func game_ready_check():
	if get_tree().network_peer != null:
		if get_tree().get_network_connected_peers().size() >= 1 and get_tree().is_network_server():
			start_game.show()
		else:
			start_game.hide()

func _player_connected(id) -> void:
	print("Player " + str(id) + " has connected")
	
	instance_player(id)
	
	game_ready_check()

func _player_disconnected(id) -> void:
	print("Player " + str(id) + " has disconnected")
	
	if Persistent_nodes.has_node(str(id)):
		Persistent_nodes.get_node(str(id)).username_text_instance.queue_free()
		Persistent_nodes.get_node(str(id)).queue_free()
	
	game_ready_check()

func _on_b_Create_server_pressed():
	if username.text != "":
		Network.current_player_username = username.text
		
		multiplayer_config_ui.hide()
		Network.create_server()
		instance_player(get_tree().get_network_unique_id())


func _on_b_Join_server_pressed():
	if username.text != "":
		Network.current_player_username = username.text
		multiplayer_config_ui.hide()
		username.hide()
		
		Global.instance_node(load("res://Server_browser/Server_browser.tscn"), self)

func _connected_to_server() -> void:
	yield(get_tree().create_timer(0.1), "timeout")
	instance_player(get_tree().get_network_unique_id())

func instance_player(id) -> void:
	var player_instance = Global.instance_node_at_location(player,Persistent_nodes, (get_node("Spawn_locations/" + str(current_spawn_location_instance_number))).global_position)
	player_instance.name = str(id)
	player_instance.set_network_master(id)
	player_instance.username = username.text
	current_spawn_location_instance_number += 1

func _on_b_Start_game_pressed():
	rpc("switch_to_game")

sync func switch_to_game() -> void:
	
	var world = load("res://World/World.tscn")
	
	for child in Persistent_nodes.get_children():
		if child.is_in_group("Player"):
			child.update_god_mode(false)
	
	Global.world = Global.instance_node_at_location(world, Persistent_nodes,Vector2.ZERO)
	
	
	get_tree().change_scene("res://Game/Game.tscn")

