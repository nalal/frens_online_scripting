extends Node

onready var configs_path = "configs"
onready var custom_path = "custom"
onready var data_path = "data"
onready var settings_config_path = configs_path + "/settings.ini"
onready var server_encryption_key = "password"

var PORT = 25565
var MAX_PLAYERS = 16
var tic_rate = 16
var start_level
var rcon_pass = "unset"

func _ready():
	check_all_filesystems()
	load_configs()

func load_configs():
	load_settings_config()

func check_all_filesystems():
	check_filesystem(configs_path)
	check_filesystem(custom_path)
	check_filesystem(data_path)
	pass

func check_filesystem(path):
	var dir = Directory.new()
	dir.open(".")
	if !dir.dir_exists(path):
		print("Folder '" + path + "' not found, rebuilding...")
		dir.make_dir(path)
	pass

func load_settings_config():
	var config_data = ConfigFile.new()
	if config_data.load(settings_config_path) == OK:
		for entry in config_data.get_section_keys("network"):
			var entryval = config_data.get_value("network", entry)
			if entry == "tic_rate":
				print("TIC RATE: " + str(entryval))
				tic_rate = entryval
			elif entry == "port":
				print("PORT: " + str(entryval))
				PORT = entryval
			elif entry == "max_players":
				print("MAX PLAYERS: " + str(entryval))
				MAX_PLAYERS = entryval
			elif entry == "start_level":
				print("START LEVEL: " + entryval)
				start_level = entryval
			elif entry == "rcon_pass":
				print("RCON PASS IS SET")
				rcon_pass = entryval
			elif entry == "server_encryption_key":
				print("SERVER ENCRYPTION KEY SET")
				server_encryption_key = entryval
	else:
		print("Failed loading config")
	if rcon_pass == "unset":
				print("RCON PASS IS NOT SET, RCON DISABLED")

func get_port():
	return PORT

func get_player_max():
	return MAX_PLAYERS

func get_tic():
	return tic_rate

func set_start_level(level):
	print("Start level is set to '" + level + "'")
	start_level = level

func get_start_level():
	return start_level
