extends WindowDialog

#nothing here works as intended yet, this is all signal placeholders
onready var key_to_bind
onready var bind_given = false
onready var list = $il_bindings_list
onready var bind_popup = $request_binding
onready var b_bind = $b_bind
onready var b_reset = $b_reset
onready var b_save = $b_save
onready var b_accept = $request_binding/b_accept
onready var b_clear = $b_clear
onready var l_bind = $request_binding/l_bind
onready var keybinds = {}
onready var polling_input = false

func _ready():
	list.add_item("Action", null, false)
	list.add_item("Key", null, false)
	for key in globals.settingsConfig.get_section_keys("keybinds"):
		var keyval = globals.settingsConfig.get_value("keybinds", key)
		keybinds[key] = keyval
		list.add_item(key)
		if typeof(keyval) == TYPE_STRING:
			print("Loaded bind '" + key + " = " + keyval + "'")
			list.add_item(keyval, null, false)
		else:
			print("Loaded bind '" + key + " = " + OS.get_scancode_string(keyval) + "'")
			list.add_item(OS.get_scancode_string(keyval), null, false)

func _input(event):
	if event is InputEventMouseMotion:
		pass
	elif event is InputEventKey:
		if polling_input:
			bind_given = true
			b_accept.disabled = false
			key_to_bind = event.scancode
			l_bind.text = OS.get_scancode_string(event.scancode)

func _on_b_bind_pressed():
	key_to_bind = 0
	l_bind.text = "Press any key to bind"
	b_bind.disabled = true
	b_reset.disabled = true
	b_clear.disabled = true
	b_save.disabled = true
	polling_input = true
	bind_popup.popup()

func _on_b_clear_pressed():
	var index = list.get_selected_items()
	if index.size() > 0:
		list.set_item_text(index[0] + 1, "undbound")

func _on_b_reset_pressed():
	pass 


func _on_b_save_pressed():
		var i = 2
		while i < list.get_item_count():
			var key = list.get_item_text(i)
			var value = OS.find_scancode_from_string(list.get_item_text(i + 1))
			globals.settingsConfig.set_value("keybinds", key, value)
			i += 2
		globals.save_config()

func _on_request_binding_popup_hide():
	b_bind.disabled = false
	b_reset.disabled = false
	b_clear.disabled = false
	b_save.disabled = false
	polling_input = false
	b_accept.disabled = true


func _on_b_accept_pressed():
	if bind_given:
		var index = list.get_selected_items()
		if index.size() > 0:
			list.set_item_text(index[0] + 1, OS.get_scancode_string(key_to_bind))
		bind_popup.hide()


func _on_b_cancel_pressed():
	bind_popup.hide()
