extends Control

#options menu scripting

onready var binding_list = $pu_binding_list
onready var le_render_dist = $le_render_dist

func _ready():
	var config_data = ConfigFile.new()
	if config_data.load(globals.get_settings_config_file_path()) == OK:
		for key in config_data.get_section_keys("video"):
			var keyval = config_data.get_value("video", key)
			if key == "render_distance":
				if typeof(keyval) == TYPE_INT:
					le_render_dist.text = keyval
				else:
					print("Render distance set to incorrect value type, using default")
					le_render_dist.text = globals.get_render_distance()
	else:
		print("Config file not located, generating new.")

#open bindings menu
func _on_b_bindings_pressed():
	binding_list.popup()


func _on_b_back_pressed():
	get_tree().change_scene("res://levels/main_menu.tscn")


func _on_b_save_pressed():
	if le_render_dist.text.is_valid_integer():
		globals.set_render_distance(int(le_render_dist.text))
#	var config_data = ConfigFile.new()
#	if config_data.load(globals.get_settings_config_file_path()) == OK:
