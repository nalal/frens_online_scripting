extends Node

signal command_sent
signal server_tic

func _ready():
	pass

func connect_node_to_signal(node_path,signal_to_check,func_to_call):
	print("Adding '" + func_to_call + "' to signal '" + signal_to_check + "' for node '" + node_path +"'")
	self.connect(signal_to_check, get_node(node_path), func_to_call)

func command_sent():
	emit_signal("command_sent")

func server_tic():
	emit_signal("server_tic")
