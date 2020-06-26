extends Node

#These will not change durring server runtime so can be made const
const CONFIGS_PATH = "configs"
const CUSTOM_PATH = "custom"
const DATA_PATH = "data"

#This is a concat with another path so must be a var
onready var settings_config_path = CONFIGS_PATH + "/settings.ini"
onready var encryption_key_path = CONFIGS_PATH + "/encryption_key.ini"

onready var server_encryption_key
onready var config_data = ConfigFile.new()
onready var encryption_key_config = ConfigFile.new()
onready var rand_generator = RandomNumberGenerator.new()

#list of mods to be loaded on connect
var mod_list = []
#Example entry for mod list for the sake of mental stability
#var mod_entry = {
#	"name":"mod_name",
#	"type":"(ENUM) MOD_TYPE",
#	"link":"URL"
#}


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

# Encryption Enabled
var encryption_enabled = false
# Encryption Key
var encryption_key
# Encryption Status
# if encryption_enabled returns true and we have a valid key, this becomes true 
var encryption_status = false

func _ready():
	print("\n[==GLOBAL DATA HANDLER STARTED==]")
	# Get a Randomized seed for RNG
	randomize()
	check_all_filesystems()
	load_configs()
	freshStart = false

#Load config data
func load_configs():
	load_settings_config()
	port = config_data.get_value("network", "port")
	max_players = config_data.get_value("network", "max_players")
	tic_rate = config_data.get_value("network", "tic_rate")
	start_level = config_data.get_value("network", "start_level")
	rcon_pass = config_data.get_value("network", "rcon_pass")
	ip_address = config_data.get_value("network", "ip_address")
	encryption_enabled = config_data.get_value("encryption", "enabled")
	if encryption_enabled:
		encryption_key = encryption_key_config.get_value("encryption", "encryption_key")
		if encryption_key != null || "":
			encryption_status = true

#Add mod to server's mod list
#[mod_name] = name of mod, will be saved as "mod_name".pck (string)
#[mod_type] = type of mod (enum::MOD_TYPE)
#[mod_link] = link to download mod (string) (default = "")
func add_mod(mod_name, mod_type, mod_link = ""):
	var mod_entry = {
		"name":mod_name,
		"type":mod_type,
		"link":mod_link
	}
	mod_list.push_back(mod_entry)

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
	config_data.save(settings_config_path)
	if config_data.get_value("encryption", "enabled"):
		encryption_key_config.save(encryption_key_path)

#Parse settings and load any missing as default 
func load_missing_settings():
	var config_changes = 0
	if not config_data.has_section_key("network", "port"):
		config_data.set_value("network", "port", 25565)
		config_changes += 1
	if not config_data.has_section_key("network", "tic_rate"):
		config_data.set_value("network", "tic_rate", 10)
		config_changes += 1
	if not config_data.has_section_key("network", "max_players"):
		config_data.set_value("network", "max_players", 16)
		config_changes += 1
	if not config_data.has_section_key("network", "start_level"):
		config_data.set_value("network", "start_level", "Entry Level")
		config_changes += 1
	if not config_data.has_section_key("network", "rcon_pass"):
		if debug_mode:
			print("Generating rcon_pass.")
		config_data.set_value("network", "rcon_pass", generate_random_string(16))
		config_changes += 1
	if not config_data.has_section_key("network", "ip_address"):
		config_data.set_value("network", "ip_address", "0.0.0.0")
		config_changes += 1
		# Encryption
	if not config_data.has_section_key("encryption", "enabled"):
		config_data.set_value("encryption", "enabled", false)
		config_changes += 1
	if config_data.get_value("encryption","enabled"):
		if not encryption_key_config.has_section_key("encryption", "encryption_key") or encryption_key_config.get_value("encryption","encryption_key") == "":
			print("Encryption key enabled, but a key was not found, Generating one")
			encryption_key_config.set_value("encryption","encryption_key",generate_random_string(32))
			config_changes += 1
		if not config_data.has_section_key("encryption", "encrypt_world"):
			config_data.set_value("encryption", "encrypt_world", false)
			config_changes += 1
		if not config_data.has_section_key("encryption", "encrypt_players"):
			config_data.set_value("encryption", "encrypt_players", false)
			config_changes += 1
	if config_changes > 0: 
		print("Preformed ", config_changes, " changed to Config, Saving Changes.")
		save_settings_config()

#Load config file
func load_settings_config():
	config_data.load(settings_config_path)
	encryption_key_config.load(encryption_key_path)
	# Lets add any settings that dont exist
	load_missing_settings()
	for section in config_data.get_sections():
		if debug_mode:
			print("[",section, "]")
		for entry in config_data.get_section_keys(section):
			var entry_val = config_data.get_value(section,entry)
			if debug_mode:
				print(entry, ":",entry_val)


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

func get_debugMode():
	return debug_mode

#Get max players
func get_player_max():
	return max_players

#Get server IP
func get_ip_address():
	return ip_address

func get_encryption_status():
	return encryption_status

#Get ticrate
func get_tic():
	return tic_rate

#Set specific level as starting level
#[level] = level to set as start level (string)
func set_start_level(level):
	print("Start level is set to '" + level + "'")
	start_level = level

#Update start level and issue level change command to players connected
#[level] = level name to set as start level (string)
func change_start_level(level):
	print("Changing start level to '" + level + "'")
	start_level = level
	signals.change_level()

#Get starting level
func get_start_level():
	return start_level
