extends Node

func _ready():
	print("\n[==INITIALIZING GAME DATA==]")
	#add_base_levels()
	signals.game_start()
	signals.connect_node_to_signal(get_path(), "level_handler_loaded","add_base_levels")
	pass

func add_base_levels():
	globals.nacs_test_level_id = add_level("Nac's Test Room", "res://levels/nacs_test_room.tscn")
	globals.entry_level_id = add_level("Entry Level", "res://levels/fol_entry_level.tscn")
	globals.entry_level_id = add_level("Terrible Deathmatch Map", "res://levels/fol_orange.tscn")

func add_level(level_name, level_path):
	var level_to_add = level.level_data_object.new()
	level_to_add.l_name = level_name
	level_to_add.l_path = level_path
	level.add_level(level_to_add)
