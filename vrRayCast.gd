extends RayCast

func _ready():
	get_parent().connect("button_pressed",self,"_button_pressed")
	get_parent().connect("button_release",self,"_button_released")

func _button_pressed(val):
	if val == JOY_VR_TRIGGER:
		var c = get_collider()
		if c and c.is_in_group("ui"):
			c.get_parent()._click(get_collision_point())

func _button_released(val):
	if val == JOY_VR_TRIGGER:
		var c = get_collider()
		if c and c.is_in_group("ui"):
			c.get_parent()._unclick(get_collision_point())

onready var line = $"Line3D"
var old_pos = global_transform.origin

func _process(delta):
	var pos = Vector3.FORWARD * 0.1
	if is_colliding():
		pos = global_transform.inverse() * get_collision_point()
	
	old_pos = lerp(pos,old_pos,0.99)
	line.set_point_position(1,old_pos)
