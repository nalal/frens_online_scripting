extends Node

signal game_start
signal tic_timer
signal level_handler_loaded
signal load_level
signal load_complete
signal load_models

func _ready():
	print("Signal handler started")

func load_models():
	print("Signaling for models to load.")
	emit_signal("load_models")

#signal for tic_timer
func tic_timer():
	#no debug print due to frequency of call
	emit_signal("tic_timer")

#signal for game starting
func game_start():
	print("Signaling 'game_start'")
	emit_signal("game_start")

#signal for when level load starts
func load_level():
	print("Signaling 'load_level'")
	emit_signal("load_level")

func level_handler_loaded():
	print("Signaling 'level_handler_loaded'")
	emit_signal("level_handler_loaded")

func load_complete():
	emit_signal("load_complete")

func connect_node_to_signal(node_path, signal_to_check, func_to_call):
	print("Adding '" + func_to_call + "' to signal '" + signal_to_check + "' for node '" + node_path +"'")
	self.connect(signal_to_check, get_node(node_path), func_to_call)
