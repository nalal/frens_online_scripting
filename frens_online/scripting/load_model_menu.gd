extends Control

onready var il_model_list = $il_model_list
onready var il_model_template_list = $il_model_template_list
onready var l_model = $l_model
onready var b_load = $b_load

var templates_exist = false
var selected_model
var selected_template

func _ready():
	for m in globals.get_model_list():
		il_model_list.add_item(m["name"])


func _on_il_model_list_item_selected(index):
	selected_model = il_model_list.get_item_text(index)
	il_model_list.hide()
	l_model.text = selected_model
	for m in globals.get_model_list():
		if m["name"] == selected_model:
			var temps = data.load_model_data(m["id"])
			match temps:
				false:
					il_model_template_list.add_item("No templates saved.")
					return
			templates_exist = true
			for t in temps["templates"]:
				il_model_template_list.add_item(t["template_name"])
	pass # Replace with function body.


func _on_il_model_template_list_item_selected(index):
	selected_template = il_model_template_list.get_item_text(index)
	b_load.set_disabled(false)



func _on_b_load_pressed():
	for m in globals.get_model_list():
		if m["name"] == selected_model:
			var temps = data.load_model_data(m["id"])
			for t in temps["templates"]:
				if t["template_name"] == selected_template:
					for t_setting in t["settings"]:
						globals.get_networking_node().send_player_model_data(t)
						for a in t_setting["asset_flags"]:
							match a:
								enums.M_ASSET_FLAGS.COLOR:
									level.get_current_level().get_node("player").set_player_color(t_setting["asset_id"], t_setting["asset_color"])
								enums.M_ASSET_FLAGS.TOGGLE:
									level.get_current_level().get_node("player").set_player_visibility(t_setting["asset_id"], t_setting["asset_visible"])

