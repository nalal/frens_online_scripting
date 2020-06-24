extends Node

onready var server_data

#manually set encryption key for file, if building from project !CHANGE THIS FUCKING STRING!
#(STRING CANNOT BE LONGER THAN 32 CHARACTERS)
const ENCRYPTION_KEY = "CqQG38SBzbRwxwnxD7RNUrxkCZmwCsWj"

func _ready():
	print("\n[==FILE IO HANDLER STARTED==]")
	pass


func master_pass_list_init():
	var f = File.new()
	var err
	if f.file_exists(globals.DATA_PATH + "/SERVER.fos"):
		print("Server data found, checking access key.")
		test_server_data()
	else:
		print("Creating server data.")
		create_server_data()
	return err

func create_server_data():
	var f = File.new()
	var err
	print("Creating server data.")
	f.open(globals.DATA_PATH + "/SERVER.fos", File.WRITE)
	f.store_var()
	f.close()

func add_server_data(data_add):
	var f = File.new()
	var err
	print("Creating server data.")
	f.open(globals.DATA_PATH + "/SERVER.fos", File.WRITE)
	f.store_var()
	f.close()

func test_server_data():
	var f = File.new()
	var err = f.open(globals.DATA_PATH + "/SERVER.fos", File.READ)
	match err:
		ERR_FILE_CORRUPT:
			print("Server data could not be loaded, regenerating.")
			f.close()
			create_server_data()
			return ERR_FILE_CORRUPT

func load_server_data():
	var f = File.new()
	var err = f.open(globals.DATA_PATH + "/SERVER.fos", File.READ)
	match err:
		ERR_FILE_CORRUPT:
			print("Server data could not be loaded.")
			f.close()
			return ERR_FILE_CORRUPT
	var serv_data = f.get_var()
	f.close()
	return serv_data

#check if player data exists, load if does, create if not
#[uname] = username (string)
#[passwd] = password in MD5 hash (string)
#[ip] = IP of user connected (string)
func player_data_init(uname, passwd, ip):
	var f = File.new()
	var data
	if f.file_exists(globals.DATA_PATH + "/" + uname + ".fos"):
		print("Loading data for '" + uname + "'")
		data = load_player_data(uname)
	else:
		print("Creating data for '" + uname + "'")
		data = create_player_data(uname, passwd, ip)
	return data

#create player data file
#[uname] = username (string)
#[passwd] = password in MD5 hash (string)
#[ip] = IP of user connected (string)
func create_player_data(uname, passwd, ip):
	var f = File.new()
	var err = f.open_encrypted(globals.DATA_PATH + "/" + uname + ".fos", File.WRITE, ENCRYPTION_KEY.to_ascii())
	var save_data = {
		"name" : uname,
		"password" : passwd,
		"ip" : ip
	}
	match err:
		OK:
			print("Data for player '" + uname + "' created.")
	f.store_var(save_data)
	print(str(err))
	f.close()
	return save_data

#load player data file
#[uname] = username to load
func load_player_data(uname):
	var f = File.new()
	var err = f.open_encrypted(globals.DATA_PATH + "/" + uname + ".fos", File.READ, ENCRYPTION_KEY.to_ascii())
	print(str(err))
	match err:
		ERR_FILE_CORRUPT:
			print("Could not load player data for '" + uname + "', data is corrupt.")
			f.close()
			return ERR_FILE_CORRUPT
		OK:
			print("Data for player '" + uname + "' loaded.")
	return f.get_var()

#save player data
#[uname] = name of user to load (string)
#[data] = data to save to file (var)
func save_player_data(uname, data):
	var f = File.new()
	var err = f.open_encrypted(globals.DATA_PATH + "/" + uname + ".fos", File.WRITE, ENCRYPTION_KEY.to_ascii())
	match err:
		ERR_FILE_CORRUPT:
			print("Could not load player data, data is corrupt.")
			f.close()
			return ERR_FILE_CORRUPT
	print(str(err))
	f.store_var(data)
	f.close()

#save general data, if open errors func returns ERR enum
#[data_dir] = folder data is to be saved to (string)
#[file_name] = file data is to be saved as (string)
#[data] = data to save (dictionary)
#[encrypted] = is file to be encrypted (bool) (default = false)
func save_data(data_dir, file_name, data, encrypted = false):
	match encrypted:
		true:
			var f = File.new()
			var err = f.open_encrypted(globals.DATA_PATH + "/" + data_dir + "/" + file_name + ".fos", File.WRITE, ENCRYPTION_KEY.to_ascii())
			match err:
				ERR_FILE_CORRUPT:
					print("Could not load player data, data is corrupt.")
					f.close()
					return ERR_FILE_CORRUPT
			print(str(err))
			f.store_var(data)
			f.close()
			return OK
		false:
			var f = File.new()
			var err = f.open(globals.DATA_PATH + "/" + data_dir + "/" + file_name + ".fos", File.WRITE)
			match err:
				ERR_FILE_CORRUPT:
					print("Could not load player data, data is corrupt.")
					f.close()
					return ERR_FILE_CORRUPT
			print(str(err))
			f.store_var(data)
			f.close()
			return OK

#load general data, if open errors func returns ERR enum
#[data_dir] = folder data is saved to (string)
#[file_name] = file data is to be loaded from (string)
#[encrypted] = is file encrypted (bool) (default = false)
func load_data(data_dir, file_name, encrypted = false):
	var data
	match encrypted:
		true:
			var f = File.new()
			var err = f.open_encrypted(globals.DATA_PATH + "/" + data_dir + "/" + file_name + ".fos", File.READ, ENCRYPTION_KEY.to_ascii())
			match err:
				ERR_FILE_CORRUPT:
					print("Could not load player data, data is corrupt.")
					f.close()
					return ERR_FILE_CORRUPT
			print(str(err))
			data = f.get_var()
			f.close()
		false:
			var f = File.new()
			var err = f.open(globals.DATA_PATH + "/" + data_dir + "/" + file_name + ".fos", File.READ)
			match err:
				ERR_FILE_CORRUPT:
					print("Could not load player data, data is corrupt.")
					f.close()
					return ERR_FILE_CORRUPT
			print(str(err))
			data = f.get_var()
			f.close()
	return data

