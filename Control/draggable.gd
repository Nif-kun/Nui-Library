class_name Draggable

var is_active := true #Condition for when drag and drop is enabled.
var item_ref : Control #The Control node where the CameraDrag2D is initialized in.
var action_grab : String #The name or id of the input action.
var grab_pos := Vector2.ZERO #The action pressed position within the item (or node).
var drag := false #Condition for when action is pressed or released.

#Sets initial values.
func _init(item:Control, action:String):
	item_ref = item
	action_grab = action

#Disables the drag and drop functionality.
func disable():
	is_active = false
	drag = false

#Enables the drag and drop functionality.
func enable():
	is_active = true

#Set action: used when changing action value.
func set_action(action:String):
	action_grab = action

#Returns action (String).
func get_action() -> String:
	return action_grab

#Executed within the _gui_input to get the InputEvent.
func handle_gui_input(event:InputEvent):
	if is_active:
		#Occurs when event is the same as action and reoccurs when released.
		if event.is_action(action_grab): 
			drag = !drag #Applies the opposite value of boolean. E.g. false <=> true.
			grab_pos = item_ref.get_local_mouse_position() #Sets the last click position.

#Executed within either a _physics_process or just _process.
func handle_process():
	#Note: implemented in handle_process instead of handle_input due to the fact that it can function regardless of location,
	#whether inside of [item_ref]/control node or not. As long as it is being held down, it will still function.
	#This implementation allows dragging while camera is moving. 
	if drag:
		item_ref.rect_position = item_ref.get_global_mouse_position() - grab_pos
