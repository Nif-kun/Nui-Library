class_name CameraZoom2D

var is_active := true #Condition for when slide movement is enabled.
var camera_ref : Camera2D #The Camera2D node where the CameraSlide2D is initialized in.
var action_zoom_in : String #The name or id of the input action for zooming in, typically the up mouse wheel.
var action_zoom_out: String #The name or id of the input action for zooming out, typically the down mouse wheel.
var zoom_range : PoolVector2Array = [Vector2(0.125,0.125), Vector2(4,4)] #The min and max range of zooming.
var zoom_rate := Vector2(0.125, 0.125) #The rate of zooming in or out.
var cursor_zoom := false #Condition if zooming will move towards the cursor.
var _state = zoom_state.NONE #The state of zooming, e.g. zooming in or out. Defaults to NONE.
enum zoom_state {
	NONE = 0,
	ZOOM_IN = 1,
	ZOOM_OUT = 2
}

#Sets initial values.
func _init(camera:Camera2D, zoom_in_action:String, zoom_out_action:String, zoom_on_cursor:=false, 
rate:=0.0625, min_zoom:=0.0625, max_zoom:=4.0):
	camera_ref = camera
	action_zoom_in = zoom_in_action
	action_zoom_out = zoom_out_action
	zoom_rate = Vector2(rate, rate)
	cursor_zoom = zoom_on_cursor
	set_zoom_range(min_zoom, max_zoom)
	if cursor_zoom: #The value change makes it applicable for the zoom to cursor function.
		camera_ref.global_position = Vector2.ZERO
		camera_ref.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT

#Disables the camera zoom functionality.
func disable():
	is_active = false

#Enables the camera zoom functionality.
func enable():
	is_active = true

#Set action_zoom_in: used when changing the value of action_zoom_in.
func set_action_zoom_in(action:String):
	action_zoom_in = action

#Returns action_zoom_in (String).
func get_action_zoom_in() -> String:
	return action_zoom_in

#Set action_zoom_out: used when changing the value of action_zoom_out.
func set_action_zoom_out(action:String):
	action_zoom_out = action

#Returns action_zoom_out (String).
func get_action_zoom_out() -> String:
	return action_zoom_out

#Set zoom_range: used when changing the zooming range.
func set_zoom_range(min_zoom:float, max_zoom:float):
	var min_z = min_zoom
	var max_z = max_zoom
	#Since zoom_rate should be 1:1, this should apply for both x and y:
	if min_z - zoom_rate.x <= 0: 
		min_z = zoom_rate.x
	if max_z <= 0:
		max_z = 4
	zoom_range[0] = Vector2(min_z, min_z)
	zoom_range[1] = Vector2(max_z, max_z)

#Returns zoom_range (PoolVector2Array).
func get_zoom_range() -> PoolVector2Array:
	return zoom_range

#Set zoom_rate: used when changing the rate of zooming.
func set_zoom_rate(rate:float):
	zoom_rate = Vector2(rate, rate)

#Returns zoom_rate (Vector2).
func get_zoom_rate() -> Vector2:
	return zoom_rate

#Set cursor_zoom: used when enabling/disabling zoom to cursor function.
func set_cursor_zoom(value:bool):
	cursor_zoom = value

#Returns cursor_zoom (bool).
func get_cursor_zoom() -> bool:
	return cursor_zoom

#Returns the prev_state (int) which is the state of zooming, e.g. zooming out or out.
func state() -> int: #Can only be utilized using /match/
	var prev_state = _state
	_state = zoom_state.NONE #Ensures that the value is not constant as it is used in conditions.
	return prev_state    

#BUG: global_mouse_position randomly returns very high vector values causing abrupt displacement.
#REASON: UNKNOWN... HELP!
func handle_input(event:InputEvent):
	if is_active:
		if event.is_action_pressed(action_zoom_in) and camera_ref.zoom > zoom_range[0]:
			if cursor_zoom:
				camera_ref.global_position = camera_ref.get_global_mouse_position()
				camera_ref.zoom -= zoom_rate
				camera_ref.global_position -= camera_ref.get_local_mouse_position()
			else:
				camera_ref.zoom -= zoom_rate
			if _state != zoom_state.ZOOM_IN:
				_state = zoom_state.ZOOM_IN
		elif event.is_action_pressed(action_zoom_out) and camera_ref.zoom < zoom_range[1]:
			if cursor_zoom:
				camera_ref.global_position = camera_ref.get_global_mouse_position()
				camera_ref.zoom += zoom_rate
				camera_ref.global_position -= camera_ref.get_local_mouse_position()
			else:
				camera_ref.zoom += zoom_rate
			if _state != zoom_state.ZOOM_OUT:
				_state = zoom_state.ZOOM_OUT
