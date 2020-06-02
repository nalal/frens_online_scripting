extends Label

func _ready():
	pass

#get player's name from overhead box
func get_player_name():
	return text

#set player's name in overhead box
func set_player_name(player_name):
	print("Setting player name on name box to '" + player_name + "'")
	text = player_name.capitalize() 
