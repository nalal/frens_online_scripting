extends Viewport

onready var name_box = get_node("./Control/player_name")

func _ready():
	pass

func set_puppet_name(name):
	name_box.set_player_name(name)
