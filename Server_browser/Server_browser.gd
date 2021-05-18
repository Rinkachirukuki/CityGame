extends Control

onready var server_listener = $Server_listener
onready var server_ip_text_edit = $background_panel/le_Ip_address
onready var server_container = $background_panel/VBoxContainer
onready var manual_setup_button = $background_panel/b_Manual_setup


func _ready():
	server_ip_text_edit.hide()


func _on_Server_listener_new_server(game_info):
	var server_node = Global.instance_node(load("res://Server_browser/Server_display.tscn"), server_container)
	server_node.text = "%s - %s" % [game_info.ip, game_info.name]
	server_node.ip_address = str(game_info.ip)


func _on_Server_listener_remove_server(server_ip):
	for server_node in server_container.get_children():
		if server_node.is_in_group("Server_display"):
			if server_node.ip_address == server_ip:
				server_node.queue_free()
				break


func _on_b_Manual_setup_pressed():
	if manual_setup_button.text != "Exit setup":
		server_ip_text_edit.show()
		manual_setup_button.text = "Exit setup"
		server_container.hide()
		server_ip_text_edit.call_deferred("grab_focus")
		server_ip_text_edit.text = Network.ip_address
	else:
		server_ip_text_edit.text = ""
		server_ip_text_edit.hide()
		manual_setup_button.text = "Manual setup"
		server_container.show()


func _on_b_Go_back2_pressed():
	Network.ip_address = server_ip_text_edit.text
	hide()
	Network.join_server()

func _on_b_Go_back_pressed():
	get_tree().reload_current_scene()
