extends Control

onready var cp_ent_color = $wd_panel/vbc_customizer/cp_ent_color
onready var cb_ent_enabled = $wd_panel/vbc_customizer/cb_ent_enabled
onready var wd_panel = $wd_panel

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

func get_length():
	return get_size()

func set_color(color):
	cp_ent_color.set_pick_color(color)

func _on_cp_ent_color_color_changed(color):
	pass # Replace with function body.
