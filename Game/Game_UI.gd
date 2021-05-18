extends CanvasLayer

onready var win_timer = $Control/Winner_text/Win_Timer
onready var winner = $Control/Winner_text

func _ready():
	winner.hide()

func _process(delta):
	if Global.alive_players.size() <= 1 and get_tree().has_network_peer():
		if Global.alive_players[0].name == str(get_tree().get_network_unique_id()):
			winner.show()
		
		if win_timer.time_left <= 0:
			win_timer.start()
