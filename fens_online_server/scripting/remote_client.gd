extends Spatial

#player name to be shown in game
onready var player_name
#player position to be shown in game
onready var player_pos
#player ID
onready var player_id
#player role
onready var player_role

func _ready():
	pass

func get_p_name():
	return player_name

func set_p_name(set_name):
	player_name = set_name

func set_client_name(set_name):
	get_node(".").set_name(set_name)

func set_player_pos(pos):
	player_pos = pos
	
func get_player_pos():
	return player_pos

func set_p_id(id):
	player_id = id

func get_p_id():
	return player_id

func get_p_role():
	return player_role

func set_p_role(role):
	player_role = role
