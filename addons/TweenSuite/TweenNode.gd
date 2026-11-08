## Node that uses [Tween] for animating.
##
## TweenNode is a [Node] wrapper for [Tween]. You can put it on your scene and configure from the inspector. The node can either use [TweenAnimation] resource or you can setup it from code (see [method initialize_animation]). The [Tween] is created automatically at the end of the frame when [TweenNode] is ready and is automatically bound to this node. It will also be valid as long as the node exists.
@tool
@icon("uid://4yavgmppmd22")
extends Node
class_name TweenNode

const _EARLY_ERROR = "Method called too early, Tween not initialized. Use make_tween() to force early creation."

## The resource that defines the [Tween]'s animation. If assigned, make sure to set your [member animation_root].
@export var animation: TweenAnimation:
	set(anime):
		if anime == animation:
			return
		
		animation = anime
		notify_property_list_changed()
		
		if _tween:
			_tween.kill()
			_tween = null
			make_tween()

## The path to the root node of the animation, relative to this node. All [TweenAnimation] paths use the root node as base. This is similar to [member AnimationMixer.root_node].
## [br][br]Only usable when [member animation] is assigned. It has no effect otherwise.
@export var animation_root := ^".."

@export_group("Initial Settings")

## If [code]true[/code], the [Tween] will start automatically once created.
@export var autostart: bool

## Speed of the [Tween] animations. Equivalent of using [method Tween.set_speed_scale].
@export var speed_scale: float = 1.0

## Default transition for the [Tween]'s tweeners. See [enum Tween.TransitionType].
@export_enum("Linear", "Sine", "Quint", "Quart", "Quad", "Expo", "Elastic", "Cubic", "Circ", "Bounce", "Back", "Spring") var default_transition: int

## Default easing for the [Tween]'s tweeners. See [enum Tween.EaseType].
@export_enum("In", "Out", "In Out", "Out In") var default_easing: int = Tween.EASE_IN_OUT

## If [code]true[/code], the [Tween]'s animations will be parallel by default (see [method Tween.set_parallel]). Has no effect when [member animation] is assigned.
@export var parallel: bool

@export_group("Processing Settings")

## Number of animation loops the [Tween] will do before stopping. [code]0[/code] means infinite.
@export_range(0, 9999) var loops: int = 1

## The frame during which the [Tween] will be processing. See [enum Tween.TweenProcessMode].
@export_enum("Idle", "Physics") var tween_process_mode: int

## The pause behavior of the [Tween]. See [enum Tween.TweenPauseMode].
@export_enum("Bound", "Stop", "Process") var pause_mode: int

var _tween: Tween

## Creates a reusable [Tween]. It will not go invalid once finished, which means you should call [method kill] to dispose it manually when it's no longer needed (this is done automatically when the tween is bound to a [Node]). If [param with_autostart] is [code]false[/code], the [Tween] will not be animating until you call [method Tween.play].
static func create_reusable_tween(with_autostart: bool = false) -> Tween:
	var scene_tree: SceneTree = Engine.get_main_loop()
	var tween := scene_tree.create_tween()
	tween.finished.connect(tween.stop)
	
	if not with_autostart:
		tween.stop()
	
	return tween

## Creates internal [Tween] for this node. This is done automatically after the node is  ready and has no effect once the tween is created. Use this method when you need the tween to be created earlier.
func make_tween():
	if _tween:
		return
	
	_tween = TweenNode.create_reusable_tween(autostart)
	_tween.bind_node(self).set_process_mode(tween_process_mode).set_trans(default_transition).set_ease(default_easing).set_pause_mode(pause_mode).set_loops(loops).set_parallel(parallel).set_speed_scale(speed_scale)
	
	if animation:
		_tween.set_parallel(false)
		animation.apply_to_tween(_tween, get_node(animation_root))
	else:
		initialize_animation(_tween)

## Virtual method to be implemented by the user. This method is called right after the [Tween] is created if [member animation] is not assigned. The tween is passed as a parameter, so you can use it to create animation via code.
## [codeblock]
## func initialize_animation(tween: Tween):
##     tween.tween_property($Sprite2D, "modulate:a", 0.0, 0.5)
##     tween.tween_callback(queue_free)
## [/codeblock]
func initialize_animation(tween: Tween):
	pass

## Plays the internal [Tween]. See [method Tween.play].
func play():
	assert(_tween != null, _EARLY_ERROR)
	_tween.play()

## Pauses the internal [Tween]. See [method Tween.pause].
func pause():
	assert(_tween != null, _EARLY_ERROR)
	_tween.pause()

## Stops the internal [Tween]. See [method Tween.stop].
func stop():
	assert(_tween != null, _EARLY_ERROR)
	_tween.stop()

## Returns the internal [Tween] object. Fails if the tween wasn't initialized yet.
func get_tween() -> Tween:
	assert(_tween != null, _EARLY_ERROR)
	return _tween

func _notification(what: int) -> void:
	if what == NOTIFICATION_READY:
		if not Engine.is_editor_hint():
			make_tween.call_deferred()

func _validate_property(property: Dictionary) -> void:
	if property.name == "animation_root":
		if not animation:
			property.usage = PROPERTY_USAGE_NONE
	elif property.name == "parallel":
		if animation:
			property.usage = PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY
