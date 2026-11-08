@tool
extends Control

@onready var step_container: BoxContainer = %StepContainer
@onready var timer: Timer = $Timer

var loading: bool
var root: Node

var animation: TweenAnimation

signal expanded

func _ready() -> void:
	if is_part_of_edited_scene():
		return
	
	loading = true
	for step in animation.steps:
		var step_control := add_animation_step()
		
		for tweener in step:
			add_tweener(step_control, tweener).apply_tweener()
	loading = false

func add_animation_step() -> Control:
	var animation_step: Control = preload("./EditorComponents/AnimationStep.tscn").instantiate()
	step_container.add_child(animation_step)
	animation_step.connect_signals(self)
	push_data_delayed()
	if not loading:
		expanded.emit()
	return animation_step

func update_step_headers():
	for step in step_container.get_children():
		step.update_header()

func on_new_tweener(id: int, step: Control):
	var tweener := TweenAnimation.TweenerAnimator.create(id)
	add_tweener(step, tweener)
	push_data_delayed()
	
	if step == step_container.get_child(-1):
		expanded.emit()

func add_tweener(step: Control, tweener: TweenAnimation.TweenerAnimator) -> Control:
	var tweener_editor: Control = preload("./EditorComponents/TweenerEditor.tscn").instantiate()
	tweener_editor.set_root(get_parent().owner.root_path_edit.object)
	tweener_editor.set_tweener(tweener)
	step.add_tweener(tweener_editor)
	tweener_editor.changed.connect(push_data_delayed)
	return tweener_editor

func push_data_delayed():
	timer.start()

func push_data():
	if loading:
		return
	
	var steps: Array
	for step in step_container.get_children():
		var step_data: Array
		var tweeners: Node = step.tweeners
		
		step_data.resize(tweeners.get_child_count())
		for i in step_data.size():
			step_data[i] = tweeners.get_child(i).get_data()
		
		steps.append(step_data)
	
	animation.steps = steps

func set_root(r: Node):
	root = r
	
	for step in step_container.get_children():
		for tweener in step.tweeners.get_children():
			tweener.set_root(root)
