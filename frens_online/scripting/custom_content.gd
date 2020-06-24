extends Node

onready var content_list = []
onready var mod_id = 0
onready var custom_content_dir = "./custom/"

#custom content entry class
#Use this to add custom content to the content_list array
class content_entry:
	#mod ID (int) (assigned when mod is added)
	var mod_id
	#mod name (string)
	var mod_name = "you_forgot_to_set_your_mod_name"
	#path to mod (string)
	var file_name
	#mod version (string)
	var mod_version = "you_forgot_to_set_your_version"
	#path to the mod in resource tree (string)
	var mod_path = "you_forgot_to_set_your_mod_path"

func _ready():
	print("\n[==LOADING MODS==]")
	#example of adding custom content
	#initialize variable as a content entry (see class 'content_entry)
	var base_game = content_entry.new()
	#set name for mod
	base_game.mod_name = "base_game"
	#set file name in custom content DIR (I.E.: my_mod_name/my_mod.pck)
	base_game.file_name = "NULL" #set to NULL since it must be loaded for the game to play
	#set mod version
	base_game.mod_version = globals.get_game_version()
	#set path to where in the content tree your mod is (I.E.: res://custom/your_mod_name)
	base_game.mod_path = "res://"
	#add mod to content list
	add_mod(base_game)
	load_mods()

#adds mod to content list
#[moc_info] = mod information (content_entry)
func add_mod(mod_info):
	mod_info.mod_id = mod_id
	mod_id = mod_id + 1
	content_list.push_back(mod_info)
	print("Content pack '" + mod_info.mod_name + "' loaded with ID '" + str(mod_info.mod_id) + "'")
	print("VERSION: " + mod_info.mod_version)
	#if mod_id > 1:
		#load(custom_content_dir + mod_info.file_name)

func load_mods():
	var dir = Directory.new()
	dir.open(data.CUSTOM_CONTENT)
	dir.list_dir_begin()
	var dir_list = []
	while true:
		var file = dir.get_next()
		match file:
			"":
				break
		#print(str(file))
		if str(file) != "." && str(file) != ".." && dir.current_is_dir():
			dir_list.push_back(str(file))
	for d in dir_list:
		dir.open(data.CUSTOM_CONTENT + d)
		dir.list_dir_begin()
		while true:
			var file = dir.get_next()
			match file:
				"":
					break
			if (file.rsplit(".", false, 2)).size() > 1 && (file.rsplit(".", false, 2))[1] == "pck":
				print("PCK '" + file + "' found, loading.")
				ProjectSettings.load_resource_pack(data.CUSTOM_CONTENT + d + "/" + file)
				var config_data = ConfigFile.new()
				#print(data.CUSTOM_CONTENT + d + "/" + (file.rsplit(".", false, 2))[0] + ".ini")
				if config_data.load(data.CUSTOM_CONTENT + d + "/" + (file.rsplit(".", false, 2))[0] + ".ini") == OK:
					var mod_to_add = content_entry.new()
					for key in config_data.get_section_keys("datapath"):
						var keyval = config_data.get_value("datapath", key)
						if key == "path":
							mod_to_add.mod_path = "res://mods/" + keyval
						if key == "name":
							mod_to_add.mod_name = keyval
						if key == "version":
							mod_to_add.mod_version = keyval
					add_mod(mod_to_add)
					#print(mod_to_add.mod_path)
					var mod = load(mod_to_add.mod_path).instance()
					add_child(mod)
					print("=PCK '" + mod_to_add.mod_name + "' loaded.")
				else:
					print("Error loading mod config")
			#print(str(file))
		#ProjectSettings.load_resource_pack(path_to_pack)
	pass
