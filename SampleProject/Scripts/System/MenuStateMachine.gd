extends Node
class_name MenuStateMachine

@export var initial_state: MenuState
@export var menu: InventoryMenu
@export var polyphonic_audio_player: PolyphonicMenuAudio

var current_state: MenuState
var states: Dictionary = {}

func _ready():
	for child in get_children():
		if child is MenuState:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transition)
			child.menu = menu
			child.sound = polyphonic_audio_player
		
	if initial_state:
		initial_state.enter()
		current_state = initial_state
	
func _process(delta):
	if current_state:
		current_state.Update(delta)
	
func _physics_process(delta: float) -> void:
	if current_state:
		current_state.Physics_Update(delta)

func on_child_transition(state, new_state_name):
	if state != current_state:
		return
	
	var new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
		
	if current_state:
		current_state.exit()
		
	new_state.enter()
	current_state = new_state
