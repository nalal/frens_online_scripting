extends WindowDialog

var models_list

onready var rtl_model_list = $rtl_model_list
onready var model_render_area = $vc_model_view/v_model_render/s_model_render_plane
onready var model_render_port = $vc_model_view/v_model_render
onready var vc_model_view = $vc_model_view
onready var b_open_model_list = $b_open_model_list
onready var l_placeholder = $l_placeholder
onready var il_parts = $il_parts
onready var b_save = $b_save
onready var wd_save = $wd_save
onready var le_name = $wd_save/vbc_template/le_name
onready var b_load = $b_load
onready var wd_load = $wd_load
onready var il_templates = $wd_load/il_templates
onready var b_load_name = $wd_load/b_load_name
onready var customizer_box

var first_load = true
var loaded_model
var cur_color
var cur_visible
var flags
var templates
var selected_load

func _ready():
	models_list = globals.get_model_list()
	for m in models_list:
		rtl_model_list.add_item(m["name"])
	pass
	model_render_port.set_size(vc_model_view.get_size())

func _physics_process(delta):
	pass

#Load new color on mouse click or release
func _input(event):
	if Input.is_action_just_pressed("ui_click") || Input.is_action_just_released("ui_click"):
		match loaded_model:
			null:
				return
		match customizer_box:
			null:
				return
		for f in flags:
			match f:
				enums.M_ASSET_FLAGS.COLOR:
					set_color()
				enums.M_ASSET_FLAGS.TOGGLE:
					set_visibility()
		return

#Get color from buffer and set part(s) as color 
func set_color():
	match cur_color:
		null:
			cur_color = customizer_box.color_selected
	loaded_model.set_part_color(customizer_box.get_window_name(), cur_color)
	cur_color = null

#Get toggle buffer and set part as buffer
func set_visibility():
	match cur_visible:
		null:
			cur_visible = customizer_box.get_render_toggle()
			return
	loaded_model.set_part_visibility(customizer_box.get_window_name(), customizer_box.get_render_toggle())
	cur_color = null

#Load models from list
func _on_b_open_model_list_pressed():
	rtl_model_list.show()

func _on_rtl_model_list_item_selected(index):
	for m in models_list:
		if m["name"] == rtl_model_list.get_item_text(index):
			var m_load = load(m["path"])
			#m_load.set_name(m["name"])
			var add = m_load.instance()
			#add.set_name(m["name"])
			model_render_area.add_child(add, true)
			b_open_model_list.text = m["name"]
			l_placeholder.hide()
			loaded_model = model_render_area.get_node(add.get_name())
	load_buttons()
	il_parts.show()
	rtl_model_list.hide()
	b_save.set_disabled(false)

func load_buttons():
	var assets = loaded_model.get_assets()
	il_parts.clear()
	for a in assets:
		il_parts.add_item(a.asset_id)
	var saved_templates = data.load_model_data(loaded_model.get_name())
	match saved_templates:
		false:
			return
	templates = saved_templates
	b_load.set_disabled(false)

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
	customizer_box.set_color(loaded_model.get_part_color(selected_asset.asset_id))
	flags = selected_asset.asset_flags

#when window is closed, remove customizer window if open
func _on_wd_customize_hide():
	clear_box_buffer()
	match first_load:
		true:
			first_load = false
			return
	if loaded_model != null:
		loaded_model.get_parent().remove_child(loaded_model)
	get_parent().remove_child(self)

#Custom asset part info
var custom_save ={
	"asset_id" : "",
	"asset_color" : "",
	"asset_visible" : true,
	"asset_flags" : []
}

#Model customization template
var model_template = {
	"template_name" : "",
	"settings" : []
}

#Open save prompt
func _on_b_save_pressed():
	wd_save.show()

func _on_b_save_name_pressed():
	match le_name.text.length():
		0:
			return
	var settings_list = []
	var parts_dict = loaded_model.get_parts()
	var assets = loaded_model.get_assets()
	for a in assets:
		var save_data ={
			"asset_id" : "",
			"asset_color" : "",
			"asset_visible" : true,
			"asset_flags" : []
		}
		save_data["asset_flags"] = a.asset_flags
		save_data["asset_id"] = a.asset_id
		for af in a.asset_flags:
			match af:
				enums.M_ASSET_FLAGS.COLOR:
					save_data["asset_color"] = loaded_model.get_part_color(a.asset_id)
				enums.M_ASSET_FLAGS.TOGGLE:
					save_data["asset_visible"] = loaded_model.get_part_visibility(a.asset_id)
		#globals.get_networking_node().send_player_model_data(save_data)
		settings_list.push_back(save_data)
	print(str((settings_list[0])["asset_flags"]))
	print(str((settings_list[0])["asset_id"]))
	print(str((settings_list[0])["asset_color"]))
	print(str((settings_list[0])["asset_visible"]))
	var save_obj = model_template
	save_obj["template_name"] = le_name.text
	save_obj["settings"] = settings_list
	data.save_model_data(loaded_model.get_name(), save_obj)
	load_buttons()
	le_name.text = ""
	wd_save.hide()
#	data.test_save(loaded_model.get_name())

#Load template from file data
func load_template(template):
	for t in template["settings"]:
		#globals.get_networking_node().send_player_model_data(t)
		for a in t["asset_flags"]:
			print(str(t))
			match a:
				enums.M_ASSET_FLAGS.COLOR:
					loaded_model.set_part_color(t["asset_id"], t["asset_color"])
				enums.M_ASSET_FLAGS.TOGGLE:
					loaded_model.set_part_visibility(t["asset_id"], t["asset_visible"])
		print(t)

func _on_b_load_pressed():
	wd_load.show()
	for t in templates["templates"]:
		il_templates.add_item(t["template_name"])

func _on_b_load_name_pressed():
	for t in templates["templates"]:
		if t["template_name"] == il_templates.get_item_text(selected_load):
			load_template(t)
	wd_load.hide()
	pass # Replace with function body.

func _on_il_templates_item_selected(index):
	selected_load = index
	b_load_name.set_disabled(false)
	pass # Replace with function body.
