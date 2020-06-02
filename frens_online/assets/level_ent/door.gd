extends Spatial

enum {OPEN_TIMED, OPEN_TOGGLE, OPEN_BOTH}

onready var placeholders = [$door_pos/placeholder_door_pos, $door_pos/placeholder_door_pos, $door_pos/placeholder_door_pos]
onready var door_pos = $door_pos
onready var close_pos = $close_pos
onready var open_pos = $open_pos
onready var open_timer = $Timer
var open_time = 1
var open_type = OPEN_TIMED
var is_open = false

func _ready():
	for p in placeholders:
		p.hide()
	close_door()

func set_open_type(type):
	open_type = type

func on_touch():
	match open_type:
		OPEN_TIMED:
			begin_timer()
			open_door()
		OPEN_TOGGLE:
			toggle_door()
		OPEN_BOTH:
			begin_timer()
			toggle_door()

func toggle_door():
	match is_open:
		true:
			close_door()
		false:
			open_door()

func begin_timer():
	match is_open:
		false:
			open_timer.set_wait_time(open_time)
			open_timer.start(0)

func open_door():
	is_open = true
	door_pos.set_global_transform(open_pos.get_global_transform())

func close_door():
	is_open = false
	door_pos.set_global_transform(close_pos.get_global_transform())

func set_open_time(time):
	open_time = time

func _on_Timer_timeout():
	close_door()
