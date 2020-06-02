extends Control

onready var loading_message = $l_loading_message

func _ready():
	signals.connect_node_to_signal(get_path(), "load_complete","kill_yourself")
	pass

func set_loading_message(message):
	loading_message.text = message

#self terminate function because for some fucking reason it spawns this ent with a bunch of fucking letters and numbers
func kill_yourself():
	get_parent().remove_child(self)
