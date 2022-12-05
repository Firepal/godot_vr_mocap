extends Spatial

var ovrinit = preload("res://addons/godot_ovrmobile/OvrInitConfig.gdns")
var ovrperf = preload("res://addons/godot_ovrmobile/OvrPerformance.gdns")

func init_vr():
	var oculusquest = ARVRServer.find_interface("OVRMobile")
	if oculusquest:
		ovrinit = ovrinit.new()
		ovrperf = ovrperf.new()
		
		ovrinit.set_render_target_size_multiplier(0.5)
		if oculusquest.initialize():
			get_viewport().arvr = true
			get_viewport().msaa = 0
	
	
	var openvr = ARVRServer.find_interface("OpenVR")
	if openvr and openvr.initialize():
			get_viewport().arvr = true
			get_viewport().msaa = 0
			OS.vsync_enabled = false

onready var head = $"ARVROrigin/head"
onready var hand_l = $"ARVROrigin/hand_l"
onready var hand_r = $"ARVROrigin/hand_r"

onready var uibox = $"UIbox"

var nodes_to_capture = []
var capture_arrays = {}
var capturing = false

onready var points_text = uibox.get_node("Viewport/setup/points_recorded")

func _ready():
	OS.request_permissions()
	init_vr()
	
	nodes_to_capture = [head,hand_l,hand_r]
	
	uibox.connect("on_capture",self,"_capture")
	
	# TODO: Implement framerate UI
	Engine.iterations_per_second = 60
	
	# Issue a button press for debugging on desktop
#	uibox._press_capture()

func _capture(state):
	if not capturing:
		capture_arrays = {}
	
	if not state and capturing:
		write(capture_arrays)
	
	capturing = state

class FancyPos:
	var position : Vector3 = Vector3()
	var quat : Quat = Quat()
	var delta : float = 1.0 / 90.0
	
	func from_xform(xform : Transform, dt : float = 0) -> FancyPos:
		var f = self
		f.position = xform.origin
		f.quat = Quat(xform.basis)
		f.delta = dt
		return f

func _add_line(strr):
	points_text.text += strr+'\n'

func _process_capture(delta):
	if nodes_to_capture.size() < 1:
		return
	
	points_text.text = ""
	
	for node in nodes_to_capture:
		var array = null
		var nh = node
		
		if nh in capture_arrays:
			array = capture_arrays[nh]
		else:
			array = []
			capture_arrays[nh] = array
		
		var f = FancyPos.new().from_xform(node.global_transform, delta)
		
		
		array.push_back(f)
		_add_line(str(node.name,": ",array.size()))

func _physics_process(delta):
	if capturing:
		_process_capture(delta)

#func _process(delta):
#	var frms = Engine.get_idle_frames()-100
#	if frms < 0:
#		if frms == -1:
#			uibox._press_capture()
#			write(capture_arrays)

static func _ftos(f : float) -> String:
	return str(f)
#	return "%0.4f" % f

static func bvh_vec3tos(v : Vector3):
	var s = _ftos(v.x)+" "+_ftos(v.y)+" "+_ftos(v.z)
	return s

static func bvh_rot3tos(v : Vector3):
	var s = _ftos(v.x)+" "+_ftos(v.y)+" "+_ftos(v.z)
	return s


func make_joint(node : Spatial):
	var s = "JOINT "
	# six decimals
	s += node.name + " \n{\n"
	
	var ine = "OFFSET " + bvh_vec3tos(node.translation) + "\n"
	ine += "CHANNELS 6 Xposition Yposition Zposition Xrotation Yrotation Zrotation\n"
	ine += "End Site\n{\n"
	ine += ("OFFSET " + bvh_vec3tos(Vector3.UP*0.1) + "\n").indent("\t")
	ine += "}\n"
	
	s += ine.indent("\t")
	
	s += "}\n"
	return s


func get_dir():
	if OS.get_name() == "Android":
		return OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS).get_base_dir()
	else:
		return OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)

func write(cap : Dictionary):
	capturing = false
	print("Writing file")
	var f = File.new()
	f.open(get_dir()+"/test.bvh",File.WRITE)
	
	f.store_string("HIERARCHY\nROOT __0\n{\n")
	
	var hier_str = "OFFSET 0.0 0.0 0.0\nCHANNELS 0\n"
	
	for node in cap.keys():
		node = node as Spatial
		var arr = cap[node]
#		print(arr)
		hier_str += make_joint(node)
	
	f.store_string(hier_str.indent("\t"))
	f.store_string("}\n")
	
	
	var frms = cap[cap.keys()[0]].size()
	
	f.store_string("MOTION\n")
	f.store_string("Frames: " + str(frms) + "\n")
	f.store_string("Frame Time: " + _ftos(1.0/60.0) + "\n")
	
	var s = ""
	for frame in range(frms):
		for node in cap.keys():
			var fp = cap[node][frame]
			var pos = fp.position
			var rot = (fp.quat as Quat).get_euler() * (180.0/PI)
#			print(str(frame)," ",node.name,": ",cap[node][frame])
			s += bvh_vec3tos(pos) + " " + bvh_vec3tos(rot) + " "
		s += "\n"
	
	f.store_string(s)
	f.store_string("\n")
	
	f.close()
	
	return OK
