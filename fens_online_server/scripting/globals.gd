extends Node

#These will not change durring server runtime so can be made const
const CONFIGS_PATH = "configs"
const CUSTOM_PATH = "custom"
const DATA_PATH = "data"

#This is a concat with another path so must be a var
onready var settings_config_path = CUSTOM_PATH + "/settings.ini"
onready var server_encryption_key
onready var config_data = ConfigFile.new()

onready var rand_generator = RandomNumberGenerator.new()
var debug_mode = false
var freshStart = true

#Server port
var port
#Maximum players per server
var max_players
#Server ticrate
var tic_rate
#Starting level to load
var start_level
#RCON password
var rcon_pass
#Server bind IP
var ip_address

func _ready():
	check_all_filesystems()
	load_configs()
	freshStart = false

#Load config data
func load_configs():
	load_settings_config()
	load_missing_settings()

#Go through required filesystems and check for existence
func check_all_filesystems():
	check_filesystem(CONFIGS_PATH)
	check_filesystem(CUSTOM_PATH)
	check_filesystem(DATA_PATH)
	pass

#Check for path in server DIR
#[path] = path to check (string)
func check_filesystem(path):
	var dir = Directory.new()
	dir.open(".")
	if !dir.dir_exists(path):
		print("Folder '" + path + "' not found, rebuilding...")
		dir.make_dir(path)

#Save config data to config file
func save_settings_config():
	load_missing_settings()
	config_data.save(settings_config_path)

#Parse settings and load any missing as default 
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
		
		#	May not want to set encryption key on load, server data will be encrypted with it so any random changes to this
		#could result in data loss due to loss of generated key, perhaps it should be stored in a file somewhere in the 
		#server's DIR, we'll have too see I guess, works for now so w/e.
		if not config_data.has_section_key("network", "server_encryption_key"):
			if debug_mode:
				print("Generating server_encryption_key.")
			server_encryption_key = config_data.set_value("network", "server_encryption_key", generate_random_string(32))

#Load config file
func load_settings_config():
	if config_data.load(settings_config_path) == OK:
		if config_data.has_section("network"):
			for entry in config_data.get_section_keys("network"):
				var entryval = config_data.get_value("network", entry)
				match entry:
					"tic_rate":
						print("TIC RATE: ", entryval)
						tic_rate = entryval
					"port":
						print("PORT: ", entryval)
						port = entryval
					"max_players":
						print("MAX PLAYERS: ", entryval)
						max_players = entryval
					"start_level":
						print("START LEVEL: ", quote(entryval))
						start_level = entryval
					"rcon_pass":
						print("RCON PASS IS SET")
						rcon_pass = entryval
					"ip_address":
						print("IPADDRESS: ", entryval)
						ip_address = entryval
					"server_encryption_key":
						print("SERVER ENCRYPTION KEY SET")
						server_encryption_key = entryval
		else:
			print("invalid Config, Attempting Repair...")
			reload_settings()
	else:
		# We should really panic and kill it here, but meh, let it try and fix it anyway.
		# - Phoenix
		# Might be right, though what if the config folder/files are missing? Might not be a fequent concern but never know.
		# - Nac
		reload_settings()

func reload_settings():
	if freshStart == false:
		print("Reloading Config")
	
	save_settings_config()
	load_settings_config()

#Generate string of given length
#[length] = length of string to generate (int)
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

#Wrap string in quotation marks
#[string] = string to wrap (string)
func quote(string):
	return "'" + string + "'" # Try to keep string quotes as " and in string quotes as '

#Get server port
func get_port():
	return port

#Get max players
func get_player_max():
	return max_players

#Get server IP
func get_ip_address():
	return ip_address

#Get ticrate
func get_tic():
	return tic_rate

#Set specific level as starting level
#[level] = level to set as start level (string)
func set_start_level(level):
	print("Start level is set to '" + level + "'")
	start_level = level

#Get starting level
func get_start_level():
	return start_level
