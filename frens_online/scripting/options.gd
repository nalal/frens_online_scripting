extends Control

#options menu scripting

onready var binding_list = $pu_binding_list
onready var le_render_dist = $le_render_dist

func _ready():
	for key in globals.settingsConfig.get_section_keys("graphics"):
		var keyval = globals.settingsConfig.get_value("graphics", key)
		# This can be extented if we have an array of all expected settings - Phoenix
		if key == "render_distance":
			if typeof(keyval) == TYPE_INT:
				le_render_dist.text = str(keyval)
			else:
				print("Render distance set to incorrect value type")

#open bindings menu
func _on_b_bindings_pressed():
	binding_list.popup()


func _on_b_back_pressed():
	get_tree().change_scene("res://levels/main_menu.tscn")


func _on_b_save_pressed():
	# If you plan on having multiple settings here, u should store them as some kinda array
	# It'd make it easier to extend this - Phoenix
	if le_render_dist.text.is_valid_integer():
		globals.set_render_distance(int(le_render_dist.text))
		globals.settingsConfig.set_value("graphics", "render_distance", int(le_render_dist.text))
		globals.save_config()
	else:
		print("Render Distance must be an number.")
