extends Node

enum {NAME_PACKET, MESSAGE_PACKET, POS_PACKET, REQUEST_TICK_PACKET, COMMAND_PACKET, OBJ_PACKET, PHYS_INTERACT_PACKET, THROW_PACKET, MOVE_PACKET, OBJ_UPDATE_PACKET, PLAYER_MODEL_DATA_PACKET, MODEL_ID_PACKET}

puppet var start_level
onready var tic_timer
onready var local_id
onready var level_load = $level_buffer
var connected = false
remote var tic_rate = 10

func _ready():
	globals.set_networking_node(get_node("/root/game"))
	var loading_screen = load("res://levels/LOADING.tscn").instance()
	var level_buff = get_node("level_buffer")
	level_buff.add_child(loading_screen)
	get_node("level_buffer/LOADING").set_loading_message("Connecting...")
	connect_server(globals.get_server_ip(), globals.get_server_port())
	signals.connect_node_to_signal(globals.get_networking_node().get_path(), "on_model_changed", "update_model_id")

#connect to server from IP,PORT
#[server_ip] = IP of server to connect to
#[server_port] = PORT of server to connect to
func connect_server(server_ip, server_port):
	globals.is_kicked = false
	globals.set_kick_message(null)
	print("Connecting to '" + server_ip + ":" + str(server_port) + "'")
	var network = NetworkedMultiplayerENet.new()
	#set connection failed function
	get_tree().connect("connection_failed", self, "_on_connection_failed")
	#set connection completed function
	get_tree().connect("connected_to_server", self, "_on_connection_success")
	get_tree().connect("server_disconnected", self, "_on_connection_lost")
	#start client and connect to server
	network.create_client(globals.get_server_ip(), globals.get_server_port())
	get_tree().set_network_peer(network)
	local_id = get_tree().get_network_unique_id()
	print("Local ID is '" + str(local_id) + "'")

#if unable to connect, do this
func _on_connection_failed():
	globals.is_kicked = true
	globals.set_kick_message("Failed to connect to server.")
	print("Connection to '" + globals.get_server_ip() + ":" + str(globals.get_server_port()) + "' failed.")

#whe player loses connection, do this
func _on_connection_lost():
	print("Connection to server lost.")
	globals.is_kicked = true
	get_tree().change_scene("res://levels/main_menu.tscn")

#when connected, do this
func _on_connection_success():
	globals.set_is_connected()
	print("Connected to '" + globals.get_server_ip() + str(globals.get_server_port()) + "'.")
	login_player()
	tic_timer = get_node("./tic_timer")
	send_packet(null, REQUEST_TICK_PACKET)

#load start level set by server
puppet func load_start_level():
	level.load_level(level.get_level_from_list(start_level))

#send message to server
#[message] = message to send
func send_message(message):
	if message != "":
		#if command is for server, send to server
		if message.begins_with("/"):
			send_packet(message, COMMAND_PACKET)
		#if command is for local client send to client
		elif message.begins_with("!"):
			process_local_command(message)
		#if is not command, send message
		else:
			send_packet(message.to_ascii(), MESSAGE_PACKET)
	else:
		print("Message cannot be blank.")

#get local command and process it
#[command] = command to process (string)
func process_local_command(command):
	var command_array = command.split(" ")
	match command_array[0]:
		"!customize":
			var custom_menu = load("res://assets/load_model_menu.tscn").instance()
			add_child(custom_menu)
			get_node(custom_menu.get_name()).show()
			return
		"!help":
			var player = get_node("/root/game/level_buffer/Level/player")
			player.load_message("!customize:\n    Load custom model templates.")
	var player = get_node("/root/game/level_buffer/Level/player")
	player.load_message("Invalid command '" + command + "'")

func update_model_id(model_id):
	send_packet(model_id.to_ascii(), MODEL_ID_PACKET)

puppet func set_puppet_model(model_id, id):
	if id != local_id:
		print("Got model ID '" + model_id.get_string_from_ascii() + "' from ID " + str(id))
		for m in globals.get_model_list():
			if m["name"] == model_id.get_string_from_ascii():
				get_puppet(id).set_puppet_model_id(m["id"])
				return

#send player name to server
#[player_name] = name to send
func send_name(player_name):
	send_packet(player_name.to_ascii(), NAME_PACKET)

puppet func sync_level_entities(list):
	level.syncd_level_entities = list

#get current map from server
func request_current_map():
	var map = ""
	return map

#send data to ID, defaults to server
#[packet] = data to send ([any])
#[type] = type of packet to send (enum)
#[id] = ID to send to, (default = 1) (int) don't change unless you know what you're doing
func send_packet(packet, type, id = 1):
	match type:
		POS_PACKET:
			rpc_unreliable_id(id, "send_player_pos", packet)
			return
		OBJ_UPDATE_PACKET:
			rpc("update_obj_pos", packet)
			return
		MESSAGE_PACKET:
			rpc_id(id, "_message_recieved", packet)
			return
		NAME_PACKET:
			rpc_id(id, "_name_recieved", packet)
			return
		REQUEST_TICK_PACKET:
			rpc_id(id, "request_tic_rate")
			return
		COMMAND_PACKET:
			rpc_id(id, "command_send", packet.to_ascii())
			return
		OBJ_PACKET:
			rpc_id(id, "sync_obj", packet)
			return
		PHYS_INTERACT_PACKET:
			rpc_id(id, "update_phys", packet)
			return
		MOVE_PACKET:
			rpc_id(id, "send_move", packet)
			return
		PLAYER_MODEL_DATA_PACKET:
			rpc_id(id, "send_model_data", packet)
			return
		MODEL_ID_PACKET:
			rpc_id(id, "update_player_model", packet)
			return
	print("INVALID PACKET TYPE " + str(type))

#get message from server then load to chatbox, I know I spelt it wrong
#[id] = ID of sender
#[data] = message data (in ascii binary format)
puppet func message_recieved(id, data):
	var message = data.get_string_from_ascii()
	print("Recieved packet '" + message + "'")
	var player = get_node("/root/game/level_buffer/Level/player")
	player.load_message(message)

puppet func move_player(move_type, move_val, id):
	match id:
		local_id:
			return
	var puppet_to_update = get_puppet(id)
	match move_type:
		enums.MOVE_TYPE.FORWARD:
			puppet_to_update.moving_forward = move_val
		enums.MOVE_TYPE.BACKWARD:
			puppet_to_update.moving_back = move_val
		enums.MOVE_TYPE.LEFT:
			puppet_to_update.moving_left = move_val
		enums.MOVE_TYPE.RIGHT:
			puppet_to_update.moving_right = move_val

func sync_obj(obj):
	send_packet(obj, OBJ_PACKET)

func send_throw_obj(throw_val):
	rpc("recieve_throw_obj", throw_val)

func send_obj_pickup(obj):
	rpc("recieve_obj_pickup", obj.to_ascii())

remote func recieve_obj_pickup(obj):
	match get_tree().get_rpc_sender_id():
		local_id:
			return
	var picker = get_node("/root/game/level_buffer/Level/" + str(get_tree().get_rpc_sender_id()))
	picker.grab_obj(obj.get_string_from_ascii())

remote func recieve_throw_obj(throw_val):
	match get_tree().get_rpc_sender_id():
		local_id:
			return
	var thrower = get_node("/root/game/level_buffer/Level/" + str(get_tree().get_rpc_sender_id()))
	thrower.throw_obj(throw_val)

puppet func start_tic_timer():
	tic_timer.set_wait_time(1.0 / float(tic_rate))
	tic_timer.start(0)

func start_timer():
	pass

#update puppet location
#[id] = ID of puppet to update
#[pos] = position to set puppet to
puppet func update_puppet_pos(id, pos):
	if id != local_id:
		var puppet_to_update = get_puppet(id)
		puppet_to_update.puppet_initpos(pos)

#load puppet from server
#[id] = player ID to assign to puppet from server
#[data] = name to assign to puppet
puppet func load_player(id, data, position = get_spawn()):
	if id != local_id:
		var cur_level = get_node("/root/game/level_buffer/Level")
		var puppet_ent = load("res://assets/puppet.tscn").instance()
		puppet_ent.set_puppet_id(str(id))
		cur_level.add_child(puppet_ent, true)
		var puppet_loaded = get_node("/root/game/level_buffer/Level/" + str(id))
		puppet_loaded.puppet_setname(data.get_string_from_ascii())
		puppet_loaded.puppet_initpos(position)

#get kick message from server
#[message] = message from server for disconnect reason (ASCII)
puppet func kick_msg(message):
	globals.set_kick_message(message.get_string_from_ascii())

#send login info to server
func login_player():
	rpc_id(1, "send_login", globals.get_name(), globals.get_pass().md5_text())
	send_name(globals.get_name())

#disconnect from server
func request_disconnect():
	get_tree().set_network_peer(null)
	print("Disconnected from server.")

#get spawn node
func get_spawn():
	return get_node("/root/game/level_buffer/Level").get_spawn_node_pos()

#send info to play animation
#[anim] = animation to play
func send_anim_to_server(anim):
	rpc_id(1, "anim_send", anim)

#get info for animation to play on puppet
#[id] = ID of puppet to animate (int)
#[anim] = animation to play (string)
puppet func rec_anim(id, anim):
	if id != local_id:
		get_puppet(id).play_animation(anim)

#delete puppet entity for disconencted player
#[id] = ID of puppet to unload
puppet func unload_player(id):
	if id != local_id:
		var targ_puppet = get_puppet(id)
		targ_puppet.remove_puppet()

#get puppet by ID
#[id] = ID of puppet node to get
func get_puppet(id):
	var puppet_loaded = get_node("/root/game/level_buffer/Level/" + str(id))
	return puppet_loaded

#for every tic, do this
func _on_tic_timer_timeout():
	signals.tic_timer()
	update_player_pos(null)
	

#update player position on server
puppet func update_player_pos(arg):
	var player_pos_send = get_node("/root/game/level_buffer/Level/player").get_player_gpos()
	send_packet(player_pos_send,POS_PACKET)

func send_player_move(move_type, move_val):
	var move_packet = [move_type, move_val]
	send_packet(move_packet, MOVE_PACKET)

func send_player_model_data(model_data):
	send_packet(model_data, PLAYER_MODEL_DATA_PACKET)

#sets the current level loaded from server
#[level] = level to be loaded (string)
puppet func set_level(level):
	globals.set_current_level(level)

puppet func change_level(level):
	level.load_level(level)

puppet func send_obj_pos():
	for o in level.get_obj_pos():
		send_packet(o, OBJ_UPDATE_PACKET)

remote func update_obj_pos(obj):
	level.get_level_entity(obj[0]).set_pos(obj[1])
	level.get_level_entity(obj[0]).throw(obj[2])

puppet func update_model(model_data, id):
	match id:
		local_id:
			return
	print(str(model_data))
	get_puppet(id).set_puppet_model([model_data])
