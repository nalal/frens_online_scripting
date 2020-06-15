extends Node

#path list
onready var config_path = "configs"
onready var custom_path = "custom_data"
onready var binding_config_file_path = config_path + "/bindings.ini"

#global variable list
onready var config_data
onready var g_name
onready var g_pass
onready var server_ip = "192.168.1.210"
onready var server_port = 25565
onready var connected_to_server = false
onready var networking
onready var game_ver_major = 0
onready var game_ver_minor = 0
onready var game_ver_patch = 0
#onready var game_ver = "v0.0.1"
const release_build = "CLOSED ALPHA "
onready var current_level
onready var render_distance = 100

#kick handler
var kick_message
var is_kicked = false

#global player scale
var p_scale = Vector3()

#internal level IDs
var nacs_test_level_id
var entry_level_id
var orange_level_id
var fol_world_id

#model list
var model_list = []

func _ready():
	print("\n[==LOADING GLOBALS AND RUNNING STARTUP CHECKS==]")
	check_all_filesystems()
	load_configs()
	load_models()

func set_p_scale(scale):
	p_scale = scale

func get_p_scale():
	return p_scale

func load_models():
	print("\n[==LOADING BASE MODELS==]")
	var horse_model = {
		"name":"Horse",
		"id":"hors",
		"path":"res://assets/models/hors.tscn"
	}
	add_model_to_list(horse_model)
	print("Signaling for custom models.")
	signals.load_models()

func get_kick_message():
	if kick_message == null:
		return "You have been disconnected."
	return kick_message

func set_kick_message(message):
	is_kicked = true
	kick_message = message

func set_render_distance(dist):
	render_distance = dist

func add_model_to_list(model):
	print("Adding '" + model["name"] + "' to model list.")
	model_list.push_back(model)

func get_model_list():
	return model_list

func get_render_distance():
	return render_distance

var keybinds = {}

func get_binding_config_path():
	return binding_config_file_path

func check_all_filesystems():
	check_filesystem(config_path)
	check_filesystem(custom_path)

func check_filesystem(path):
	var dir = Directory.new()
	if !dir.dir_exists(path):
		print("Folder '" + path + "' not found, rebuilding...")
		dir.open(".")
		dir.make_dir(path)
	pass

func load_configs():
	load_binds_config()

func load_binds_config():
	config_data = ConfigFile.new()
	if config_data.load(binding_config_file_path) == OK:
		for key in config_data.get_section_keys("keybinds"):
			var keyval = config_data.get_value("keybinds", key)
			if typeof(keyval) != TYPE_STRING:
				print("Loaded bind '" + key + " = " + OS.get_scancode_string(keyval) + "'")
			else:
				print("Loaded bind '" + key + " = " + keyval + "'")
			keybinds[key] = keyval
	else:
		print("Config file not located, generating new.")
		generate_binding_config()
	set_binds()

func set_binds():
	for key in keybinds.keys():
		var val = keybinds[key]
		if typeof(val) != TYPE_STRING:
			var action_list = InputMap.get_action_list(key)
			if !action_list.empty():
				InputMap.action_erase_event(key, action_list[0])
			var new_key = InputEventKey.new()
			new_key.set_scancode(val)
			InputMap.action_add_event(key, new_key)
			print("Bind set for '" + key + "' to '" + str(val) + "'")
		else:
			print("Not binding '" + key + "' as it is set to '" + str(val) + "'")

#get player name
func get_name():
	return g_name

#set player name
#[name_set] = name to set global player name as (string)
func set_name(name_set):
	g_name = name_set

#get player pass
func get_pass():
	return g_pass

#set player name
#[pass_set] = name to set global player pass as (string)
func set_pass(pass_set):
	g_pass = pass_set

#set global IP to connect to when loading in game (will most likely be depricated and changed to a more dynamic system)
#[ip] = IP to connect to (string)
func set_server_ip(ip):
	server_ip = ip

#get ip to connect to (see set_server_ip for more info)
func get_server_ip():
	return server_ip

#set port to use when connecting
#[port] = port number (int)
func set_server_port(port):
	server_port = port

#get port to use when connecting
func get_server_port():
	return server_port

#is player connected (depricated and non-functional)
func get_is_connected():
	return connected_to_server

#invert player connected bool (depricated)
func set_is_connected():
	connected_to_server = !connected_to_server

#set node for networking calls
#[node] = node entity to call to (node)
func set_networking_node(node):
	networking = node

#get node for networking calls
func get_networking_node():
	return networking

#get game version
func get_game_version():
	return "v" + str(game_ver_major) + "." + str(game_ver_minor) + "." + str(game_ver_patch)

#get build type
func get_release_build():
	return release_build

#set the current level to load
func set_current_level(level):
	current_level = level

#set the current level to load
func get_current_level():
	return current_level

#yes it's hideous but it doesn't read from pck packaged text files
var bindings_template = "[keybinds]\naction_boop=81\nmove_forward=87\nmove_back=83\nmove_left=65\nmove_right=68\nmove_crouch=16777238\nchat_enter=16777221\nmove_camera_lock=90\nmove_jump=32\nmove_fly=86\nmove_reset_cam=67\n[video]\nrender_distance=100"
func generate_binding_config():
	print("Generating default config for '" + binding_config_file_path + "'.")
	var file = File.new()
	file.open(binding_config_file_path, File.WRITE)
	file.store_string(bindings_template)
	file.close()
	print("Writing template.")
