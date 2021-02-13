class_name CameraDrag2D

#Note: velocity_scale and deceleration may still need some tuning to attain a cleaner easing motion.
#Definitions:
#[Easing] - position transition caused by pulling and releasing from grab or drag; a flicking motion.
#[Unfinished easing] - occurance when both action_grab and action_drag was suddenly released while easing.

var is_active := true #Condition for when drag movement is enabled.
var camera_ref : Camera2D #The Camera2D node where the CameraDrag2D is initialized in.
var action_drag : String #The name or id of the input action for dragging, typically the left mouse button.
var action_grab : String #The name or id of the input action for grabbing, typically the space key.
var velocity_scale := 0.3 setget set_velocity_scale, get_velocity_scale #[0-1]: velocity speed in decimal range.
var deceleration := 500.0 #The amount deducted per frame to velocity.
var velocity := Vector2.ZERO setget set_velocity, get_velocity #Speed=distance
var grab_pos := Vector2.ZERO #The action pressed position within global space.
var release_pos := Vector2.ZERO #The action released position within global space.
var grab := false #Condition for when action_grab is pressed or released.
var drag := false #Condition for when action_drag is pressed or released.
var held_down := false #Condition for when action_drag and action_grab is pressed or released.
var moving := false #Condition when camera is moving.
var toggle_mode := false #Condition if action_grab can be toggled.
var easing_mode := false #Condition if pulling and releasing from grab will glide the camera depending on distance of pull.

#Sets initial values.
func _init(camera:Camera2D, grab_action:String, drag_action:String, mode_toggle := false, mode_easing := false):
	camera_ref = camera
	action_grab = grab_action
	action_drag = drag_action
	toggle_mode = mode_toggle
	easing_mode = mode_easing

#Disables the drag camera motion functionality.
func disable():
	is_active = false
	grab = false
	drag = false
	moving = false

#Enables the drag camera motion functionality.
func enable():
	is_active = true

#Set action_grab: used when changing the action_grab value.
func set_action_grab(action:String):
	action_grab = action

#Returns action_grab (String).
func get_action_grab() -> String:
	return action_grab

#Set action_grab: used when changing the action_drag value.
func set_action_drag(action:String):
	action_drag = action

#Returns action_drag (String).
func get_action_drag() -> String:
	return action_drag

#Set velocity_scale: used when changing the speed of velocity; forces the value to stay on the range of 0 to 1.
func set_velocity_scale(value:float):
	if value > 1.0:
		velocity_scale = 1.0
	elif value < 0.0:
		velocity_scale = 0.0
	else:
		velocity_scale = value

#Returns velocity_scale (float).
func get_velocity_scale() -> float:
	return velocity_scale

#Set deceleration: used when changing the decrease rate of velocity when [easing]; acts as a form of friction.
func set_deceleration(value:float):
	deceleration = value

#Returns deceleration (float).
func get_deceleration() -> float:
	return deceleration

#Set velocity: used when setting a predefined velocity when [easing]. It is advised not to be used unless knowledgeable.
func set_velocity(value:Vector2):
	velocity = value * velocity_scale

#Returns velocity (Vector2).
func get_velocity() -> Vector2:
	return velocity

#Set toggle_mode: used when enabling or disabling toggle_mode.
func set_toggle_mode(value:bool):
	toggle_mode = value
	#making sure everything stops when changing value.
	disable()
	enable()

#Returns toggle_mode (bool)
func get_toggle_mode() -> bool:
	return toggle_mode

#Set easing_mode: used when enabling or disabling easing_mode.
func set_easing_mode(value:bool):
	easing_mode = value

#Returns easing_mode (bool)
func get_easing_mode() -> bool:
	return easing_mode

#Executed within the _input to get the InputEvent when pressing peripheral buttons such as keys or mouse button.
func handle_input(event:InputEvent):
	if is_active and (event is InputEventKey or event is InputEventMouseButton):
		
		#Action grab state: occurs when event is the same as action and reoccurs when released.
		if event.is_action_pressed(action_grab):
			grab_pos = camera_ref.get_global_mouse_position() #Sets the last pressed position of action_grab.
			if velocity != Vector2.ZERO: #Fixes sudden displacement caused by [unfinished easing].
				velocity = Vector2.ZERO
			if toggle_mode:
				grab = !grab #false <=> true
			else:
				grab = true
		elif event.is_action_released(action_grab):
			if !toggle_mode:
				grab = false
			if easing_mode:
				release_pos = camera_ref.get_global_mouse_position() #Sets the position upon release of action_grab.
				set_velocity(grab_pos - release_pos)
		
		#Action drag state: occurs when event is the same as action and reoccurs when released.
		if event.is_action(action_drag):
			drag = !drag #false <=> true
			if drag:
				grab_pos = camera_ref.get_global_mouse_position() #Sets the last pressed position of action_drag.
				if velocity != Vector2.ZERO: #Fixes sudden displacement caused by [unfinished easing].
					velocity = Vector2.ZERO
			elif easing_mode: #drag is false and easing_mode is true
				release_pos = camera_ref.get_global_mouse_position() #Sets the position upon release of action_drag.
				set_velocity(grab_pos - release_pos)
		
		#Sets condition if both action are pressed/held down.
		if grab and drag:
			held_down = true
		elif held_down:
			held_down = false

#Executed within either a _physics_process or just _process.
func handle_process(delta:float):
	if is_active:
		if grab or drag: #Filters two [false] value, leaving only both [true] or value opposite of each other.
			if grab == drag:
				var prev_pos = camera_ref.position #Gets the position before any subsequent movements.
				#Moves the position of the camera based on the position of the mouse subtracted by the last mouse position.
				camera_ref.position -= camera_ref.get_global_mouse_position() - grab_pos
				if camera_ref.position != prev_pos: 
					moving = true
				elif moving: #Disables moving if first condition occured.
					moving = false
			elif easing_mode:
				if velocity != Vector2.ZERO: #Keeps moving until it reaches the velocity of (0,0).
					velocity = velocity.move_toward(Vector2.ZERO, delta * deceleration) #Decelerates velocity per frame.
					#The camera will move to a distance based on speed and rate of deceleration of velocity.
					camera_ref.position += velocity 
					if !moving:
						moving = true
				elif moving: #Disables moving if first condition occured.
					moving = false
		elif moving: #If both action keys were suddenly released, this will reset moving to [false] if ever [true].
			moving = false
