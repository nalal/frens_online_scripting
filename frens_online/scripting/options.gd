extends Control

#options menu scripting

onready var binding_list = $pu_binding_list
#onready var le_render_dist = $le_render_dist
#onready var le_ui_scale = $le_uiscale
onready var l_update_message = $l_update_message
onready var optNode = get_node("Options")
onready var OptionsArray = optNode.get_children()

func _ready():
	for Options in OptionsArray:
		var optionName = Options.get_name()
		var optionValue
		var optionArr = optNode.get_node(optionName).get_children()
		for objType in optionArr:
			match objType.get_class():
				"LineEdit":
					optionValue = globals.settingsConfig.get_value("graphics", optionName.to_lower())
					objType.text = str(optionValue)

#open bindings menu
func _on_b_bindings_pressed():
	binding_list.popup()


func _on_b_back_pressed():
	get_tree().change_scene("res://levels/main_menu.tscn")


func _on_b_save_pressed():
	for Options in OptionsArray:
		var update_p_config = false
		var optionName = Options.get_name()
		var optionValue
		var optionArr = optNode.get_node(optionName).get_children()
		for objType in optionArr:
			match objType.get_class():
				"LineEdit":
					optionValue = objType.text
		if optionValue.is_valid_float():
			match optionName:
				"render_distance":
					globals.set_render_distance(int(optionValue))
					globals.settingsConfig.set_value("graphics", optionName, int(optionValue))
				"render_width":
					globals.settingsConfig.set_value("graphics", optionName, int(optionValue))
				"render_height":
					globals.settingsConfig.set_value("graphics", optionName, int(optionValue))
				"framerate":
					globals.settingsConfig.set_value("graphics", optionName, int(optionValue))
					globals.update_project_config("application/run/frame_delay_msec", int(round(1000 / float(optionValue))))
					update_p_config = true
				_:
					globals.settingsConfig.set_value("graphics", optionName, float(optionValue))
		if update_p_config:
			l_update_message.show()
			globals.save_project_config()

	globals.save_config()
	globals.update_video_settings()
