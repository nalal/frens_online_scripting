extends Node

onready var configs_path = "configs"
onready var custom_path = "custom"
onready var data_path = "data"
onready var settings_config_path = configs_path + "/settings.ini"
onready var server_encryption_key
onready var config_data = ConfigFile.new()

onready var rand_generator = RandomNumberGenerator.new()
var debug_mode = false
var freshStart = true

var port
var max_players
var tic_rate
var start_level
var rcon_pass
var ip_address

func _ready():
	check_all_filesystems()
	load_configs()
	freshStart = false

func load_configs():
	load_settings_config()
	load_missing_settings()
	
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
	
# Save
func save_settings_config():
	load_missing_settings()
	config_data.save(settings_config_path)


func load_missing_settings():
	# var config_data = ConfigFile.new()
	if config_data.load(settings_config_path) == OK:
		if not config_data.has_section_key("network", "port"):
			port = config_data.set_value("network", "port", 25565)
	
		if not config_data.has_section_key("network", "tic_rate"):
			tic_rate = config_data.set_value("network", "tic_rate", 10)
	
		if not config_data.has_section_key("network", "max_players"):
			max_players = config_data.set_value("network", "max_players", 16)
	
		if not config_data.has_section_key("network", "start_level"):
			start_level = config_data.set_value("network", "start_level", "Entry Level")
			
		if not config_data.has_section_key("network", "rcon_pass"):
			if debug_mode:
				print("Generating rcon_pass.")
			rcon_pass = config_data.set_value("network", "rcon_pass", generate_random_string(16))
		
		if not config_data.has_section_key("network", "ip_address"):
			ip_address = config_data.set_value("network", "ip_address", "0.0.0.0")
			
		if not config_data.has_section_key("network", "server_encryption_key"):
			if debug_mode:
				print("Generating server_encryption_key.")
			server_encryption_key = config_data.set_value("network", "server_encryption_key", generate_random_string(32))
			

func load_settings_config():

	if config_data.load(settings_config_path) == OK:
		if config_data.has_section("network"):
			for entry in config_data.get_section_keys("network"):
				var entryval = config_data.get_value("network", entry)
				if entry == "tic_rate":
					print("TIC RATE: ", entryval)
					tic_rate = entryval
				elif entry == "port":
					print("PORT: ", entryval)
					port = entryval
				elif entry == "max_players":
					print("MAX PLAYERS: ", entryval)
					max_players = entryval
				elif entry == "start_level":
					print("START LEVEL: ", quote(entryval))
					start_level = entryval
				elif entry == "rcon_pass":
					print("RCON PASS IS SET")
					rcon_pass = entryval
				elif entry == "ip_address":
					print("IPADDRESS: ", entryval)
					ip_address = entryval
				elif entry == "server_encryption_key":
					print("SERVER ENCRYPTION KEY SET")
					server_encryption_key = entryval
		else:
			print("invalid Config, Attempting Repair...")
			reload_settings()
	else:
		# We should really panic and kill it here, but meh, let it try and fix it anyway.
		# - Phoenix
		reload_settings()
func reload_settings():
	if freshStart == false:
		print("Reloading Config")
	
	save_settings_config()
	load_settings_config()

func generate_random_string(length):
	var generated_string = ""
	var buffer = PoolByteArray()
		
	var char_count = length
	while char_count > 0:
		var letter = ""
		var char_set = randi() % 3
		match char_set:
			0: # A-Z
				letter = rand_generator.randi_range(65,90)
			1: # a-z
				letter = rand_generator.randi_range(97,112)
			2:  # 0-9
				letter = rand_generator.randi_range(48,57)
		buffer.append(letter)
		char_count -= 1

	generated_string = buffer.get_string_from_ascii()
	if generated_string.length() < length:
		print("This is longer than it should be, Da fuck?") 
	if debug_mode: 
		print("[generate_random_string]: ", str(generated_string))

	return str(generated_string)

func quote(string):
	return '"' + string + '"'

func get_port():
	return port

func get_player_max():
	return max_players
	
func get_ip_address():
	return ip_address
	
func get_tic():
	return tic_rate

func set_start_level(level):
	print("Start level is set to '" + level + "'")
	start_level = level

func get_start_level():
	return start_level
