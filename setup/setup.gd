extends Spatial

onready var v = $"Viewport"
onready var s = $"StaticBody"
onready var button = $"Viewport/setup/Button"

signal on_capture(state)

func _ready():
	button.connect("button_down",self,"_on_capture_clicked")

var capturing = false
func _on_capture_clicked():
	capturing = not capturing
	
	if capturing:
		button.text = "Stop capturing"
	else:
		button.text = "Start capturing"
	emit_signal("on_capture",capturing)

func _press_capture():
	button.emit_signal("button_down")

func _to_mouse_pos(pos):
	var p = s.global_transform.affine_inverse() * pos
	p = Vector2(0.5,0.5)-Vector2(p.x,p.y)
	return p*v.size

func _click(pos):
	var mouse = InputEventMouseButton.new()
	mouse.position = _to_mouse_pos(pos)
	mouse.button_index = BUTTON_LEFT
	mouse.pressed = true
	v.input(mouse)

func _unclick(pos):
	var mouse = InputEventMouseButton.new()
	mouse.position = _to_mouse_pos(pos)
	mouse.button_index = BUTTON_LEFT
	mouse.pressed = false
	v.input(mouse)

func _mouseover(pos):
	var mouse = InputEventMouse.new()
	mouse.position = _to_mouse_pos(pos)
	v.input(mouse)
	print(mouse.position)
