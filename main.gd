extends Spatial

var ovrinit = preload("res://addons/godot_ovrmobile/OvrInitConfig.gdns")
var ovrperf = preload("res://addons/godot_ovrmobile/OvrPerformance.gdns")

func _ready():
	var oculusquest = ARVRServer.find_interface("OVRMobile")
	if oculusquest:
		ovrinit = ovrinit.new()
		ovrperf = ovrperf.new()
		
		ovrinit.set_render_target_size_multiplier(0.5)
		if oculusquest.initialize():
			get_viewport().arvr = true
			get_viewport().msaa = 6 # AndroidVR MSAAx4
	
	
	var openvr = ARVRServer.find_interface("OpenVR")
	if openvr and openvr.initialize():
			get_viewport().arvr = true
			get_viewport().msaa = Viewport.MSAA_4X

func _physics_process(delta):
	print("yo")
	printraw("/r")
