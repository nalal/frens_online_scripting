extends Node

func _ready():
	var export_config = ConfigFile.new()
	var export_config_path = "res://export_presets.cfg"
	var config_error = export_config.load(export_config_path)
	var app_name = export_config.get_value("preset.0.options", "application/product_name")
	var version = export_config.get_value("preset.0.options", "application/product_version")
	
	print("\n[==INFO==]")
	print("Operating System: ", OS.get_name())
	print("Build: ",version)
	if OS.get_cmdline_args().size() > 0:
		print("CommandLine Args: ", OS.get_cmdline_args())
	if OS.is_debug_build():
		print("Debug Build: ", OS.is_debug_build())
	print("Logs: ", OS.get_user_data_dir(), "/logs")
