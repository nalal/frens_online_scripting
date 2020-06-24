extends Control

onready var cp_ent_color = $wd_panel/vbc_customizer/cp_ent_color
onready var cb_ent_enabled = $wd_panel/vbc_customizer/cb_ent_enabled
onready var wd_panel = $wd_panel

onready var open = false

var color_selected
var render_toggle

func _ready():
	wd_panel.show()
	pass

func set_render_flags(flags):
	for f in flags:
		match f:
			enums.M_ASSET_FLAGS.COLOR:
				cp_ent_color.show()
			enums.M_ASSET_FLAGS.TOGGLE:
				cb_ent_enabled.show()

func set_window_name(set_name):
	wd_panel.set_title(set_name)

func get_window_name():
	return wd_panel.get_title()

func get_length():
	return get_size()

func set_color(color):
	cp_ent_color.set_pick_color(color)

func _on_cp_ent_color_color_changed(color):
	color_selected = color

func _on_cb_ent_enabled_toggled(button_pressed):
	render_toggle = button_pressed

func get_render_toggle():
	return render_toggle


func _on_wd_panel_popup_hide():
	get_parent().remove_child(self)
	pass # Replace with function body.


func _on_wd_panel_hide():
	match open:
		false:
			open = true
			return
	get_parent().remove_child(self)
	pass # Replace with function body.
