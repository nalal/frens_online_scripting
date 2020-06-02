extends Control

#scripting for chatbox

onready var window_label = $text_box_dialog
onready var text = $text_box_dialog/l_message

func _ready():
	pass

#load message box
#[label] = set window title to this (string)
#[message] = message text of the message box (string)
func call_message_box(label, message):
	window_label.window_title = label
	text.text = message
	window_label.popup()

#close window
func _on_b_accept_pressed():
	window_label.hide()
