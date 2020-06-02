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

#adds mod to content list
#[moc_info] = mod information (content_entry)
func add_mod(mod_info):
	mod_info.mod_id = mod_id
	mod_id = mod_id + 1
	content_list.push_back(mod_info)
	print("Content pack '" + mod_info.mod_name + "' loaded with ID '" + str(mod_info.mod_id) + "'")
	print("VERSION: " + mod_info.mod_version)
	if mod_id > 1:
		load(custom_content_dir + mod_info.file_name)
