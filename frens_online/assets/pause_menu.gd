extends Control

var binding_menu_open = false

onready var menu = $wd_menu
onready var bindings = $pu_binding_list

func _ready():
	pass

func load_menu():
	menu.show()

func _on_b_options_pressed():
	if !binding_menu_open:
		binding_menu_open = true
		bindings.show()


func _on_b_disconnect_pressed():
	globals.get_networking_node().request_disconnect()
	get_tree().change_scene("res://levels/main_menu.tscn")
	level.level_is_loaded = false


func _on_pu_binding_list_popup_hide():
	binding_menu_open = false
