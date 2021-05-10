extends Label

var ip_address = ""

func _ready():
	pass # Replace with function body.

func _on_b_join_pressed():
	Network.ip_address = ip_address
	Network.join_server()
	get_parent().get_parent().queue_free()
