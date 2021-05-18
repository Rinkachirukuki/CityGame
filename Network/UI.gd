extends CanvasLayer

func _ready():
	Global.ui = self

func _exit_tree():
	Global.ui = null
