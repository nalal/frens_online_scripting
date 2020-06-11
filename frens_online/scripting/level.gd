extends Node

var level_buffer_path = "/root/game/level_buffer"
var loading_screen_path = "res://levels/LOADING.tscn"
var levels = []
var levels_loaded = 0
var level_is_loaded = false
#syncronized entities
var syncd_level_entities = []

#object for level data to be stored in list
#[l_name] = name for level to be printed in console (string)
#[l_path] = path to level in resources
class level_data_object:
	var l_name
	var l_path

#syncronized object structure
#[o_id] = object ID (string)
#[o_path] = object path (string)
#[o_type] = object type (ENT_TYPE[enum])
class synced_obj:
	var o_id
	var o_path
	var o_type

func _ready():
	print("\n[==LEVEL HANDLER STARTED==]")
	signals.level_handler_loaded()

#get level from level list by name
#[level_name] = name to search for (string)
func get_level_from_list(level_name):
	for l in levels:
		if l.l_name == level_name:
			return l
	print("Level '" + level_name + "' not found.")
	return enums.ERR_TYPE.ERR_NOT_FOUND

func get_level_entity(ent_id):
	return get_node(level_buffer_path + "Level" + ent_id)

#load level from list by index
#[index] = index value for level (int)
func load_level_from_index(index):
	load_level(get_level_from_index(index))

#get level data from list by index
#[index] = index value for level (int)
func get_level_from_index(index):
	return levels[index]

#returns level list
func get_level_list():
	return levels

#add level to level list, returns index of level
#[level_data] = data for level (level_data_object)
func add_level(level_data):
	levels.push_back(level_data)
	levels_loaded += 1
	print("Level '" + level_data.l_name + "' added to level list with ID '" + str(levels_loaded - 1) + "'")
	return levels_loaded - 1

#spawn entity in map with either direct position or in level spawn point
#[type] = type of entity (ENT_TYPE[enums])
#[pos] = position to load (transform) (default = null)
#[spawn_point] = spawn point entity node name (string) (default = "")
#[synced] = is entity synced to server (bool) (default = false)
func spawn_ent(type, ent_id_path, pos = null, spawn_point = "", synced = false, forced_name = ""):
	match type:
		enums.ENT_TYPE.PHYS_OBJ:
			var new_id = "phys_obj_" + str(get_new_id())
			var spawn_obj = load(ent_id_path).instance()
			spawn_obj.set_asset_path(ent_id_path)
			if pos != null:
				spawn_obj.set_pos(pos)
			else:
				spawn_obj.set_pos(get_current_level().get_node(spawn_point).get_pos())
			if pos != null || spawn_point != "":
				spawn_obj.set_is_synced(synced) 
				if forced_name != "":
					spawn_obj.set_id(forced_name)
				else:
					spawn_obj.set_id(new_id)
				get_current_level().add_child(spawn_obj)
			else:
				print("Invalid spawn position params for '" + ent_id_path + "'")
			match synced:
				true:
					var obj_to_add = synced_obj.new()
					randomize()
					obj_to_add.o_id = new_id
					obj_to_add.o_path = ent_id_path
					obj_to_add.o_type = enums.ENT_TYPE.PHYS_OBJ
					syncd_level_entities.push_back(obj_to_add)
					globals.get_networking_node().sync_obj(obj_to_add)

#generate new ID for obj
func get_new_id():
	if syncd_level_entities.size() > 0:
		var not_added = true
		var new_id
		while not_added:
			randomize()
			new_id = randi()
			for o in syncd_level_entities:
				if o.o_id == "phys_obj_" + str(new_id):
					break
				not_added = false
	else:
		return randi()

#remove entity from the level
#[ent] = entity to remove (node)
func remove_ent(ent):
	match ent.get_is_synced():
		true:
			remove_ent_from_list(ent)
	get_tree().remove_node(ent.get_path())

#remove synced entity from list of synced entities
#[ent] = entity to remove (node)
func remove_ent_from_list(ent):
	var id = ent.get_obj_id()
	for e in syncd_level_entities:
		if e.o_id == id:
			syncd_level_entities.erase(e)
	return

#returns current level name
func get_level_name():
	return get_current_level().get_level_name()

#returns spawn node
#[spawn_node_name] = name of spawn node, defaults to "spawn"
func get_spawn_node(spawn_node_name = "Spawn"):
	return get_node(level_buffer_path + "/Level" + "/" + spawn_node_name)

#change level
#[level_object] = level data object to be loaded (level_data_object)
func load_level(level_object):
	var level_path = level_object.l_path
	print("Loading level '" + level_object.l_name + "'")
	signals.load_level()
	var loading_screen = load(loading_screen_path).instance()
	if level_is_loaded:
		get_node(level_buffer_path).remove_child(get_current_level())
		level_is_loaded = true
	get_node(level_buffer_path).add_child(loading_screen)
	get_node(level_buffer_path).load_level(level_path)

#returns current level as a node
func get_current_level():
	return get_node(level_buffer_path + "/Level")

func get_obj_pos():
	var pos_data = []
	for o in syncd_level_entities:
		var o_node = get_level_entity(o.o_id)
		var add_data = [o_node.get_obj_id(), o_node.get_pos(), o_node.get_obj_velocity()]
		pos_data.push_back(add_data)
	return pos_data
