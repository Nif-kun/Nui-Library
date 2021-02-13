class_name CameraSlide2D

var is_active := true #Condition for when slide movement is enabled.
var camera_ref : Camera2D #The Camera2D node where the CameraSlide2D is initialized in.
var action_steady : String #The name or id of input action for steadying/slowing camera movement.
var action_pool : PoolStringArray #String pool of actions for (in order of): up, down, left, right.
var move_speed := 1000.0 #The speed of camera.
var move_speed_gain := 62.5 #The speed gain of camera when zoomed out.
var move_speed_loss := 0.5 #The speed loss of camera when steady.
var moving := false #Condition when an action from action_pool is pressed, thus considered moving.

#Sets initial values.
func _init(camera:Camera2D, up_action:String, down_action:String, left_action:String, right_action:String):
	camera_ref = camera
	action_pool.resize(4)
	set_action_pool(up_action, down_action, left_action, right_action)

#Disables the slide camera motion functionality.
func disable():
	is_active = false
	moving = false

#Enables the slide camera motion functionality.
func enable():
	is_active = true

#Set action_pool: used when changing the action_pool values.
func set_action_pool(up_action:String, down_action:String, left_action:String, right_action:String):
	action_pool.set(0, up_action)
	action_pool.set(1, down_action)
	action_pool.set(2, left_action)
	action_pool.set(3, right_action)

#Returns action_pool (PoolStringArray).
func get_action_pool() -> PoolStringArray:
	return action_pool

#Enables and sets the action_steady: used when allowing a certain key to slow down the camera when pressed.
func apply_steady_key(action:String):
	action_steady = action

#Disables and erases the value of action_steady.
func remove_steady_key():
	action_steady = ""

#Returns the action_steady (String).
func get_steady_key() -> String:
	return action_steady

#Increments move_speed based on the given value. Default is based on move_speed_gain.
func increase_speed(value:float=62.5):
	move_speed += value

#Decrements move_speed based on the given value. Default is based on move_speed_gain.
func decrease_speed(value:float=62.5):
	if move_speed - value > 0:
		move_speed -= value

#Set move_speed: used when changing move_speed value.
func set_move_speed(value:float):
	move_speed = value

#Returns move_speed (float).
func get_move_speed() -> float:
	return move_speed

#Set move_speed_gain: used when changing move_speed_gain value.
func set_move_speed_gain(value:float):
	move_speed_gain = value

#Returns move_speed_gain (float).
func get_move_speed_gain() -> float:
	return move_speed_gain

#Set move_speed_loss: used when changing move_speed_loss value.
func set_move_speed_loss(value:float):
	move_speed_loss = value

#Returns move_speed_loss (float).
func get_move_speed_loss() -> float:
	return move_speed_loss

#Returns a normalized value (-1 to 1) based on the action keys pressed. E.g. [up = -1] and [down = 1].
func _get_direction() -> Vector2:
	var direction = Vector2(Input.get_action_strength(action_pool[3]) - Input.get_action_strength(action_pool[2]), 
	Input.get_action_strength(action_pool[1]) - Input.get_action_strength(action_pool[0])).normalized()
	return direction

#Executed within the _input to get the InputEvent when pressing peripheral buttons such as keys or mouse button.
func handle_input(event:InputEvent):
	#Note: implemented in handle_input due to the fact that the value of moving is set per frame in handle_process.
	#Necessary to attain movement status that can be used for local or gloabl checking. 
	if event is InputEventKey and is_active:
		if (_get_direction() != Vector2.ZERO): 
			if !moving: #Avoids repeat.
				moving = true
		else:
			moving = false

#Executed within either a _physics_process or just _process.
func handle_process(delta:float):
	if is_active and moving:
		if(action_steady.length() > 0 and Input.is_action_pressed(action_steady)): #occurs when steady key is held down.
			#The calculation below simply gets the direction and is multiplied by the value of delta(frame) * move_speed.
			#Delta is important as it stabilizes the movement based on fps. 
			#In this condition, move_speed_loss is also applied and is used to decrease speed.
			#It uses point decimal value in multiplication to keep the value in it's original state. 
			#E.g. negative if negative; positive if positive.
			camera_ref.position += _get_direction() * (delta * move_speed * move_speed_loss)
		else:
			camera_ref.position += _get_direction() * (delta * move_speed)
