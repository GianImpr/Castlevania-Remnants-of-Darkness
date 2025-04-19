extends Node

var children: Array[RigidBody2D]
@export var eventID: int
@export var passcode: Array[int]
@export var platform_reveal_delay_timer: Timer
@export var platforms: Node
@onready var sound: PolyphonicAudio = $PolyphonicAudio


func _ready():
	for child in get_children():
		if child is RigidBody2D:
			children.append(child)
			
	if Global.player.stats.event_flags[eventID]:
		for i in range(0, children.size()):
			children[i].label.text = str(passcode[i])
		
func _process(delta):
	if Global.player.stats.event_flags[eventID]:
		return
		
	if verifyNumber():
		Global.player.stats.event_flags[eventID] = true
		for child in children:
			if child.animation.is_playing():
				child.animation.stop()
			child.animation.play("clear")
			sound.play_sound_effect_from_library("activate")
			child.hurtbox.monitoring = false
		platform_reveal_delay_timer.start()

func verifyNumber():
	for i in range(0, 3):
		if not passcode[i] == children[i].number:
			return false
	return true

func showPlatforms():
	for platform in platforms.get_children():
		platform.animation.play("reveal")
		platform.activated(true)


func _on_timer_timeout() -> void:
	showPlatforms()
