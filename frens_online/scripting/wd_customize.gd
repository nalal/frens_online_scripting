extends WindowDialog

var models_list

onready var rtl_model_list = $rtl_model_list
onready var model_render_area = $vc_model_view/v_model_render/s_model_render_plane
onready var model_render_port = $vc_model_view/v_model_render
onready var vc_model_view = $vc_model_view
onready var b_open_model_list = $b_open_model_list
onready var l_placeholder = $l_placeholder
onready var il_parts = $il_parts
onready var customizer_box

var loaded_model

func _ready():
	models_list = globals.get_model_list()
	for m in models_list:
		rtl_model_list.add_item(m["name"])
	pass
	model_render_port.set_size(vc_model_view.get_size())


func _on_b_open_model_list_pressed():
	rtl_model_list.show()


func _on_rtl_model_list_item_selected(index):
	for m in models_list:
		if m["name"] == rtl_model_list.get_item_text(index):
			var m_load = load(m["path"]).instance()
			model_render_area.add_child(m_load)
			b_open_model_list.text = m["name"]
			l_placeholder.hide()
			loaded_model = model_render_area.get_node(m_load.get_name())
	load_buttons()
	il_parts.show()
	rtl_model_list.hide()

func load_buttons():
	var assets = loaded_model.get_assets()
	for a in assets:
		il_parts.add_item(a.asset_id)


#func load_controls():
#	var assets = loaded_model.get_assets()
#	for a in assets:
#		var setting_box = load("res://assets/model_customize_item.tscn").instance()
#		setting_box.set_name(a.asset_id + "_box")
#		vbc_boxes.add_child(setting_box, true)
#		var added_box = vbc_boxes.get_node(a.asset_id + "_box")
#		added_box.set_render_flags(a.asset_flags)
#		added_box.rect_min_size = sc_options_list.get_size()
#		var len_add = added_box.get_length()
#		var new_size = vbc_boxes.get_size()
#		new_size.y = new_size.y + len_add.y
#		vbc_boxes._set_size(new_size)

#check if customization window exists, if does then close
func clear_box_buffer():
	match customizer_box:
		null:
			return
	remove_child(customizer_box)
	customizer_box = null

#when part is selected, open customizer box with flags from part
func _on_il_parts_item_selected(index):
	clear_box_buffer()
	var assets = loaded_model.get_assets()
	var target = il_parts.get_selected_items()[0]
	var selected_asset = assets[target]
	var setting_box = load("res://assets/model_customize_item.tscn").instance()
	setting_box.set_name(selected_asset.asset_id + "_box")
	add_child(setting_box, true)
	customizer_box = get_node(selected_asset.asset_id + "_box")
	#customizer_box = added_box
	customizer_box.set_render_flags(selected_asset.asset_flags)
	customizer_box.set_window_name(selected_asset.asset_id)

#when window is closed, remove customizer window if open
func _on_wd_customize_hide():
	clear_box_buffer()
