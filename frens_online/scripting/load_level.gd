extends Node

onready var level_dir = "res://levels/"

func _ready():
	pass

#load level from PCK asset
#[level] = level path
func load_level(level_path):
	get_node("LOADING").set_loading_message("Loading '" + level_path + "'")
	var attempts = 0
	var level_load = load(level_path).instance()
	add_child(level_load)
	print("Loaded level '" + level_load.get_level_name() + "'")
	var player_load = preload("res://assets/player.tscn").instance()
	get_node("./Level").add_child(player_load)

#connect to server with IP/PORT
#(think this might be redundant, will check and prune later)
func connect_to(server_ip, server_port):
	globals.get_networking_node().connect_server(server_ip, server_port)
