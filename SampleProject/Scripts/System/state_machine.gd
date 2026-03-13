extends Node
class_name StateMachine

@export var initial_state: State
@export var player: CharacterBody2D
@export var animation: AnimationPlayer
@onready var polyphonic_audio_player: AudioStreamPlayer2D = $"../PolyphonicAudioPlayer"
@export var voice: PolyphonicAudio

var new_state: State
var current_state: State
var states: Dictionary = {}

func _ready():
	for child in get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.Transitioned.connect(on_child_transition)
			child.player = player
			child.sound = polyphonic_audio_player
			child.voice = voice
			child.animation = animation
		
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
		
	if "stay_idle" in player and player.stay_idle and not new_state_name.to_lower() in player.idle_states:
		if player.reset_idle_when_staying_idle:
			current_state.enter()
			return
		else:
			return
	
	new_state = states.get(new_state_name.to_lower())
	if !new_state:
		return
		
	if current_state:
		current_state.exit()
		
	if state is HectorAttack and new_state is HectorBackdash:
		TrainingSettings.spawnTrainingHeart(TrainingMode.Training.BACKDASH_CANCEL)
		
	new_state.enter()
	current_state = new_state
