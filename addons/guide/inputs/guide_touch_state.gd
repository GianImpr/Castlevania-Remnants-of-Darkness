@tool
## Shared information about current touch state. This simplifies implementation of the touch inputs
## and avoids having to process the same events multiple times.

# Cached finger positions
static var _finger_positions:Dictionary = {}

# Events processed this frame.
static var _processed_events:Dictionary = {}

# Last frame we were called
static var _last_frame:int = -1


## Processes an input event and updates touch state. Returns true, if the given event
## was touch-related.
static func process_input_event(event:InputEvent) -> bool:
	if not event is InputEventScreenTouch and not event is InputEventScreenDrag:
		return false
	
	var this_frame = Engine.get_process_frames()
	
	# if we are in a new frame, clear the processed events
	if this_frame != _last_frame:
		_last_frame = this_frame
		_processed_events.clear()
	
	# if the event already was processed, skip processing it again
	if _processed_events.has(event):
		return true
		
	_processed_events[event] = true
	
	var index:int = event.index
	
	if event is InputEventScreenTouch:
		if event.pressed:
			_finger_positions[index] = event.position
		else:
			_finger_positions.erase(index)
	
	if event is InputEventScreenDrag:
		_finger_positions[index] = event.position
		
	return true


## Gets the finger position of the finger at the given index.
## If finger_index is < 0, returns the average of all finger positions.
## Will only return a position if the amount of fingers
## currently touching matches finger_count. 
##
## If no finger position can be determined, returns Vector2.INF.
static func get_finger_position(finger_index:int, finger_count:int) -> Vector2:
	# if we have no finger positions right now, we can cut it short here
	if _finger_positions.is_empty():
		return Vector2.INF

	# If the finger count doesn't match we have no position right now
	if _finger_positions.size() != finger_count:
		return Vector2.INF
		
	# if a finger index is set, use this fingers position, if available
	if finger_index > -1:
		return _finger_positions.get(finger_index, Vector2.INF)


	var result = Vector2.ZERO
	for value in _finger_positions.values():
		result += value
		
	result /= float(finger_count)
	return result		
