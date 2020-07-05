extends Node

func _ready():
	
	print("\n[==INFO==]")
	print("Operating System: ", OS.get_name())
	print("Build: ",ProjectSettings.get_setting("application/config/version"))
	if OS.get_cmdline_args().size() > 0:
		print("CommandLine Args: ", OS.get_cmdline_args())
	if OS.is_debug_build():
		print("Debug Build: ", OS.is_debug_build())
	print("Logs: ", OS.get_user_data_dir(), "/logs")
