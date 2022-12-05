extends Reference

class_name BVHWriter

static func write(arr):
	var f = File.new()
	f.open("res://test.bvh",File.WRITE)
	f.store_string("HIERARCHY\nROOT __0\n{")
	
	
	
	f.store_string("}")
	
	
	return OK
