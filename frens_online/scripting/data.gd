extends Node

const DATA_DIR = "data/"
const MODEL_DIR = "models/"

func _ready():
	verify_paths()
	pass

var model_data_obj = {
	"name" : "",
	"templates" : []
}

func verify_paths():
	var dir = Directory.new()
	match dir.dir_exists(DATA_DIR):
		true:
			print("Data directory located.")
		false:
			print("Data directory not found, rebuilding")
			dir.open(".")
			dir.make_dir(DATA_DIR)
			dir.make_dir(DATA_DIR + MODEL_DIR)
			return
	match dir.dir_exists(DATA_DIR + MODEL_DIR):
		true:
			print("Model directory located.")
		false:
			print("Model directory not found, rebuilding")
			dir.open(".")
			dir.make_dir(DATA_DIR + MODEL_DIR)
			return
	return

func test_save(file):
	var data_file = load_data(DATA_DIR + MODEL_DIR +file)
	for t in data_file.templates:
		print(str(t))

func load_data(path):
	var file = File.new()
	var data
	if file.open(path, File.READ) == OK:
		data = file.get_var()
		file.close()
	else:
		data = file.open(path, File.READ)
	return data
	pass

func save_data(path, data):
	var file = File.new()
	if file.open(path, File.WRITE) == OK:
		file.store_var(data)
		file.close()
	else:
		print("Failed to save file '" + path + "'")
	pass

func save_model_data(model_id, data):
	var model_data_file = DATA_DIR + MODEL_DIR + model_id
	var file = File.new()
	match file.file_exists(model_data_file):
		true:
			var model_data = load_data(model_data_file)
			model_data["name"] = model_id
			model_data["templates"].push_back(data)
			save_data(model_data_file, model_data)
		false:
			var model_data = model_data_obj
			model_data["name"] = model_id
			model_data["templates"].push_back(data)
			save_data(model_data_file, model_data)
	pass

func load_model_data(model_id):
	var model_data_file = DATA_DIR + MODEL_DIR + model_id
	var data
	var file = File.new()
	match file.file_exists(model_data_file):
		true:
			data = load_data(model_data_file)
		false:
			data = false
	return data
