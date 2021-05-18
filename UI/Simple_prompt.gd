extends Control


func _on_b_ok_pressed():
	get_tree().change_scene("res://Network/Network_setup.tscn")

func set_text(text):
	$Panel/Label.text = text
