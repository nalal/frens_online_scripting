extends Node

onready var tic_timer = $tic_timer

#position update array
var pos_update = []
#player list
var name_id_list = []
#objects to be synced on client
var synced_objs = []
#has no one loaded into the level yet
var level_fresh = true
#player data object
#[p_name] = player name (string)
#[p_id] = player ID (int)
#[p_role] = player role (ROLES[enum])
class player_data:
	var p_name
	var p_id
	var p_role

#syncronized object structure
#[o_id] = object ID (string)
#[o_path] = object path (string)
#[o_type] = object type (ENT_TYPE[enum])
class synced_obj:
	var o_id
	var o_path
	var o_type

#on ready, do this
func _ready():
	tic_timer.wait_time = globals.get_tic()
	tic_timer.start(0)
	init_conn_handler()

#Tic rate counter
func _on_connection_handler_timeout():
	pass

master func update_obj_pos(obj):
	return

#start server process
func init_conn_handler():
	var network = NetworkedMultiplayerENet.new()
	if globals.get_ip_address().is_valid_ip_address():
		network.set_bind_ip(globals.get_ip_address())
		network.create_server(globals.get_port(), globals.get_player_max())
		network.connect("peer_connected", self, "_peer_connected")
		network.connect("peer_disconnected", self, "_peer_disconnected")
		get_tree().set_network_peer(network)
		get_tree().multiplayer.connect("network_peer_packet", self, "_packet_recieved")
		print("Connection listener started.")
		if globals.get_encryption_status():
			print("Encryption is Enabled.")
		else:
			print("Encryption is Disabled.")
		
		print("Listening on ", globals.get_ip_address(),":",globals.get_port())
		print("Server ID is '" + str(get_tree().get_network_unique_id()) + "'")
		#add master to list of users connected
		_peer_connected(1)
	else:
		print("IP Address ", globals.quote(globals.get_ip_address()), " is not a valid IP Address.")
		

#when peer connects, do this
#[id] = ID of peer connected
func _peer_connected(id):
	var m_name = ""
	#if adding, master set master name
	if id == 1:
		print("Adding master node to player list.")
		m_name = "MASTER"
	#if not adding master, add normally
	else:
		rset_id(id, "start_level", globals.get_start_level())
		rpc_id(id, "load_start_level")
		print("User ID '" + str(id) + "' connected.")
	var newClient = load("res://assets/remote_client.tscn").instance()
	newClient.set_client_name(str(id))
	get_node("./players/").add_child(newClient, true)
	rpc("update_player_pos", null)
	#if master was added, add name to user node
	if m_name != "":
		_name_recieved(m_name.to_ascii())


#When user disconnects, remove entity
#[id] = ID of peer to remove (int)
func _peer_disconnected(id):
	print("User ID '" + str(id) + "' disconnected, removing player data.")
	var player_remove = get_node("./players/" + str(id))
	sys_message(-1, "Player '" + player_remove.player_name +"' disconnected")
	get_node("./players").remove_child(player_remove)
	remove_disconnected_player(id)

#When packet recieved, print
#[data] = data of message received (ASCII)
func _packet_recieved(data):
	var id = get_tree().get_rpc_sender_id()
	var message = data.get_string_from_ascii()
	print("Packet with message '" + message + "' recieved from user ID '" + str(id) + "'.")

#message handler for sending player messages 
#[data] = message sent by client (ASCII)
master func _message_recieved(data):
	var id = get_tree().get_rpc_sender_id()
	var message = data.get_string_from_ascii()
	if message != "":
		print("Packet with message '" + message + "' recieved from user ID '" + str(id) + "'.")
		message = "[" + get_player_name(id) + "]" + ": " + message
		rpc("message_recieved", id, message.to_ascii())
	else:
		print("Dropping blank message from client '" + str(id) + "'")

#send message unformatted to player (need to clean up and take account of sys_message)
#[id] = ID to send message to (int)
#[message] = message to send (ASCII)
func send_message(id, message):
	rpc_id(id, "message_recieved", message)

func check_name(peer_name):
	var invalid_names = [
		"CON",
		"PRN",
		"AUX", 
		"NUL", 
		"COM1", 
		"COM2", 
		"COM3", 
		"COM4", 
		"COM5", 
		"COM6", 
		"COM7", 
		"COM8", 
		"COM9", 
		"LPT1", 
		"LPT2", 
		"LPT3", 
		"LPT4", 
		"LPT5", 
		"LPT6", 
		"LPT7", 
		"LPT8",
		"LPT9"
	]
	for n in invalid_names:
		if n == peer_name.to_upper():
			return false
	return peer_name.is_valid_filename()

#remote call for sending new player name to server
#[data] = name received (ASCII)
master func _name_recieved(data):
	var peer_name = data.get_string_from_ascii()
	peer_name = peer_name.strip_escapes()
	var name_valid = check_name(peer_name)
	match name_valid:
		false:
			kick_player(get_tree().get_rpc_sender_id())
	var id
	if peer_name == "MASTER":
		id = 1
	else:
		id = get_tree().get_rpc_sender_id()
	print("Recieved name '" + peer_name + "' from ID '" + str(id) + "'")
	var player_node = get_player_node(id)
	player_node.set_p_name(peer_name)
	player_node.set_p_id(id)
	send_player(id, data)
	send_connected_players(id)
	sys_message(-1, "Player '" + peer_name + "' joined the server.")
	var new_player = player_data.new()
	new_player.p_name = peer_name
	new_player.p_id = id
	if id == 1:
		new_player.p_role = enums.ROLES.SERVER
	else:
		new_player.p_role = enums.ROLES.USER
		load_sync_list(id)
		#commented out due to not working on phys obj sync at this time
		#match level_fresh:
		#	false:
		#		rpc_id(get_node("players").get_child(0).get_p_id(),"send_obj_pos")
		#	true:
		#		level_fresh = false
	name_id_list.push_back(new_player)

#send message globally (deprecated, to be removed, use sys_message with ID of -1)
#[message] = message to send to everyone (string)
#func announce_players(message):
#	message = "[SYSTEM]: " + message
#	rpc("message_recieved", 1, message.to_ascii())

#send system message to ID
#[id] = ID of player to send message to (int) (if is -1 send to all connected)
#[message] = message to send to player (string)
func sys_message(id, message):
	match id:
		-1:
			message = "[SYSTEM]: " + message
			rpc("message_recieved", 1, message.to_ascii())
			return
	message = "[SYSTEM]: " + message
	rpc_id(id, "message_recieved", id, message.to_ascii())

#send all connected players to ID
#[id] = ID of player to send players to (int)
func send_connected_players(id):
	var player_list = get_node("./players/")
	for p in player_list.get_children():
		if p.get_p_id() != 1:
			rpc_id(id, "load_player", p.get_p_id(), p.get_p_name().to_ascii(), p.get_player_pos())
			for n in get_player_node(p.get_p_id()).get_model_data():
				for set in n["settings"]:
					rpc_id(id, "update_model", set, p.get_p_id())
	pass

#send move velocity data
#[move_slide_val] = value to move and slide by (Vector3)
master func send_move(move_slide_val):
	rpc("move_player", move_slide_val, get_tree().get_rpc_sender_id())

#send animation player to clients
#[anim] = animation to play (string)
master func anim_send(anim):
	rpc("rec_anim", get_tree().get_rpc_sender_id(), anim)

#remove entity for disconnected player on clients
#[id] = ID of player to remove from clients (int)
func remove_disconnected_player(id):
	rpc("unload_player", id)
	var i = 0
	for p in name_id_list:
		if p.p_id == id:
			name_id_list.remove(i)
		else:
			i += 1 

#use name to find ID of player
#[p_name] = name to find in list (string)
func get_id_from_name(p_name):
	var i = 0
	for p in name_id_list:
		if p.p_name == p_name:
			return p.p_id
		else:
			i += 1 
	return false

master func send_model_data(model_data):
	print("Sending model data for '" + str(get_tree().get_rpc_sender_id()) + "'")
	var player_to_model = get_player_node(get_tree().get_rpc_sender_id())
	player_to_model.add_model_data(model_data)
	rpc("update_model", model_data, get_tree().get_rpc_sender_id())

#remove player from the game
#[id] = ID of player to kick (int)
func kick_player(id):
	print("Player ID '" + str(id) + "' kicked")
	get_tree().get_network_peer().disconnect_peer(id)
	if get_player_node(id).get_p_name() != null:
		sys_message(-1, "Player '" + get_player_node(id).get_p_name() + "' was kicked.")
	remove_disconnected_player(id)

#send player name and ID to client to load as puppet
#[id] = ID of player to puppet (int)
#[player_name] = player name to send (ASCII)
func send_player(id, player_name):
	rpc("load_player", id, player_name)

#get player name from local node by ID
#[id] = ID to look for player name under (int)
func get_player_name(id):
	var player = get_player_node(id)
	var return_name = player.get_p_name()
	return return_name

#get player node from ID
#[id] = ID name of node to look for (int)
func get_player_node(id):
	return get_node("./players/" + str(id))


#do literally nothing lmao
func add_player_pos_to_list():
	pass

#request sending of ticrate to client
master func request_tic_rate():
	sync_tic_rate()

#set tic rate ont client
func sync_tic_rate():
	var to_id = get_tree().get_rpc_sender_id()
	rset_id(to_id, "tic_rate", globals.get_tic())
	rpc_id(to_id, "start_tic_timer")

#send player position data
#[pos] = position of player to send (global_translation)
master func send_player_pos(pos):
	var id = get_tree().get_rpc_sender_id()
	var player = get_player_node(id)
	#player.set_player_pos(pos)
	send_player_pos_global(id, pos)

#command handler
#[command] = command from client (char * \ character array in ascii)
master func command_send(command):
	var sender = get_tree().get_rpc_sender_id()
	command = command.get_string_from_ascii()
	var com_parts = command.rsplit(" ")
	var response = ""
	signals.command_sent()
	match com_parts[0]:
		#rcon command (/rcon <password>)
		"/rcon":
			if com_parts.size() == 1:
				sys_message(sender, "PLEASE PROVIDE RCON PASSWORD")
			elif globals.rcon_pass != "unset" && com_parts[1] == globals.rcon_pass:
				get_player_node(sender).set_p_role(enums.ROLES.ADMIN)
				sys_message(sender, "RCON AUTHENTICATED")
			else:
				sys_message(sender, "INVALID RCON PASS OR IS NOT SET IN CONFIG")
			return
		#kick command (/kick <player_id\player_name>)
		"/kick":
			if com_parts.size() > 1 && check_role(sender, enums.ROLES.MOD):
				kick_command(sender, com_parts[1])
			return
		#list players command (/playerlist)
		"/playerlist":
			print_ids(sender)
			return
	response = "INVALID COMMAND"
	sys_message(sender, response)

#get throw packet, send to connected players
#[obj_id] = id of object to throw in scene (string)
master func obj_throw(obj_id):
	print("ID '" + str(get_tree().get_rpc_sender_id()) + "' threw object '" + obj_id + "'")

remote func recieve_throw_obj(throw_val):
	print("Player '" + str(get_tree().get_rpc_sender_id()) + "' threw object with val '" + str(throw_val) + "'")

#kick player
#[sender] = if of person to send kick command (int)
#[kick_id] = ID of player to kick (string\int)
func kick_command(sender, kick_id):
	var targ_id = get_id_from_name(kick_id)
	if !targ_id:
		if !kick_id.is_valid_integer():
			sys_message(sender, "INVALID PLAYER ID/NAME")
		else:
			if is_player_connected(int(kick_id)):
				if compare_id_roles(sender, int(kick_id)):
					rpc_id(kick_id, "kick_msg", "You have been kicked.")
					kick_player(int(kick_id))
				else:
					sys_message(sender, "YOU DO NOT HAVE THE AUTHORITY TO KICK THIS PLAYER")
			else:
				sys_message(sender, "INVALID PLAYER ID/NAME")
	else:
		if compare_id_roles(sender, targ_id):
			rpc_id(kick_id, "kick_msg", "You have been kicked.")
			kick_player(targ_id)
		else:
			sys_message(sender, "YOU DO NOT HAVE THE AUTHORITY TO KICK THIS PLAYER")

#add object to object array
#[obj] = object to add to list ()
master func sync_obj(obj):
	match is_object_synced(obj.o_id):
		false:
			synced_objs.push_back(obj)

#check if object is already on sync list
#[obj_id] = ID of object to check for
func is_object_synced(obj_id):
	for o in synced_objs:
		if o.o_id == obj_id:
			return true
	return false

#load synced object list to client
func load_sync_list(id):
	print("Syncronizing level entities for '" + str(id) + "'")
	#if synced_objs.size() > 0:
		#rpc_id(id, "sync_level_entities", synced_objs)
	print("Sync complete")

#print connected players to chat
#[id] = ID to send player list to (int)
func print_ids(id):
	var players = "\n"
	for p in name_id_list:
		players = players +  str(p.p_id) + ":" + p.p_name + ":" + get_role_name(p.p_role) + "\n"
	sys_message(id, players)

#get name of each role
#[role] = role to print (enum\int)
func get_role_name(role):
	if role == enums.ROLES.USER:
		return "USER"
	elif role == enums.ROLES.MOD:
		return "MOD"
	elif role == enums.ROLES.ADMIN:
		return "ADMIN"
	elif role == enums.ROLES.OWNER:
		return "OWNER"
	else:
		return "[INVALID ROLE ID]"

#check if player is connected to the server
#[id] = id to check (int)
func is_player_connected(id):
	var i = 0
	for p in name_id_list:
		if p.p_id == id:
			return true
		else:
			i += 1 
	return false

#check if player role is equal to and greater than given role
#[id] = ID of user to check the role of
#[min_role] = role to check against player's role
func check_role(id, min_role):
	if get_player_node(id).get_p_role() >= min_role:
		return true
	else:
		return false

#compare the IDs of two users and return if first ID is greater or equal to second
#[id0] = first ID to check
#[id1] = second ID to check
func compare_id_roles(id0, id1):
	if get_player_node(id0).get_p_role() >= get_player_node(id1).get_p_role():
		return true
	else:
		return false

#go through player POS update list and send POS to all clients
func send_player_pos_update():
	for p in pos_update:
		send_player_pos_global(p[0], p[1])
	pass

#get when object is picked up
#[obj] = object ID that wasa picked up (ASCII)
remote func recieve_obj_pickup(obj):
	print("Player '" + str(get_tree().get_rpc_sender_id()) + "' picked up obj '" + obj.get_string_from_ascii() + "'")

#send position update for client
#[id] = ID of puppet to update client side
#[pos] = position to move puppet to
func send_player_pos_global(id, pos):
	rpc("update_puppet_pos", id, pos)

func check_players():
	if name_id_list.size() == 0:
		level_fresh = true

#logs player into server
#[username] = username of player to login (string)
#[password] = MD5 hash of password to check (string)
master func send_login(username, password):
	var id = get_tree().get_rpc_sender_id()
	var ip = get_tree().get_network_peer().get_peer_address(id)
	var player_data = data.player_data_init(username, password, ip)
	match player_data:
		ERR_FILE_CORRUPT:
			rpc_id(id, "kick_msg", ("Error loading player data.").to_ascii())
			kick_player(id)
			return
	match player_data["password"]:
		password:
			print("User '" + username + "' authenticated.")
			return
	print("User authentication failed, kicking.")
	rpc_id(id, "kick_msg", ("Invalid password.").to_ascii())
	kick_player(id)

#for every server tic, do this
func _on_tic_timer_timeout():
	send_player_pos_update()
	signals.server_tic()
	check_players()
