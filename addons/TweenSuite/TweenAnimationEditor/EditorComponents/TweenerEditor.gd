@tool
extends Control

const Type = TweenAnimation.TweenerAnimator.Type

var tweener: TweenAnimation.TweenerAnimator
var tweener_edits: Array[Node]:
	get:
		if tweener_edits.is_empty():
			tweener_edits = [
				%PropertyTweener,
				%IntervalTweener,
				%CallbackTweener,
				%MethodTweener,
				%SubtweenTweener,
				%AwaitTweener,
			]
		return tweener_edits

signal changed

func _ready() -> void:
	if is_part_of_edited_scene():
		return
	
	fill_transitions(get_data_control(Type.PROPERTY, "transition"))
	fill_eases(get_data_control(Type.PROPERTY, "easing"))
	fill_transitions(get_data_control(Type.METHOD, "transition"))
	fill_eases(get_data_control(Type.METHOD, "easing"))
	update_id()
	
func fill_transitions(button: OptionButton):
	button.add_item("Default")
	button.set_item_id(-1, -1)
	button.add_item("Linear", Tween.TRANS_LINEAR)
	button.add_item("Sine", Tween.TRANS_SINE)
	button.add_item("Quint", Tween.TRANS_QUINT)
	button.add_item("Quart", Tween.TRANS_QUART)
	button.add_item("Quad", Tween.TRANS_QUAD)
	button.add_item("Expo", Tween.TRANS_EXPO)
	button.add_item("Elastic", Tween.TRANS_ELASTIC)
	button.add_item("Cubic", Tween.TRANS_CUBIC)
	button.add_item("Circ", Tween.TRANS_CIRC)
	button.add_item("Bounce", Tween.TRANS_BOUNCE)
	button.add_item("Back", Tween.TRANS_BACK)
	button.add_item("Spring", Tween.TRANS_SPRING)

func fill_eases(button: OptionButton):
	button.add_item("Default")
	button.set_item_id(-1, -1)
	button.add_item("In", Tween.EASE_IN)
	button.add_item("Out", Tween.EASE_OUT)
	button.add_item("In Out", Tween.EASE_IN_OUT)
	button.add_item("Out In", Tween.EASE_OUT_IN)

func set_tweener(tw: TweenAnimation.TweenerAnimator):
	tweener = tw
	%Type.text = tweener.get_name()
	tweener_edits[tweener.type].show()

func get_value_property(control: Control) -> StringName:
	if control is Button and not control is OptionButton:
		return &"button_pressed"
	return &"value"

func get_data() -> TweenAnimation.TweenerAnimator:
	for property in tweener.get_serializable_properties():
		if property == "type":
			continue
		
		var data_control := get_data_control(tweener.type, property)
		tweener.set(property, data_control.get(get_value_property(data_control)))
	
	return tweener

func apply_tweener():
	for property in tweener.get_serializable_properties():
		if property == "type":
			continue
		
		var data_control := get_data_control(tweener.type, property)
		data_control.set(get_value_property(data_control), tweener.get(property))

func get_data_control(type: Type, control: String) -> Control:
	return tweener_edits[type].get_node(control)

func set_selected_id(button: OptionButton, id: int):
	for i in button.item_count:
		if button.get_item_id(i) == id:
			button.select(i)
			return
	
	push_error("Wrong ID %d for button %s" % [id, button])

func update_id():
	%ID.format(get_index())

func delete_me() -> void:
	queue_free()
	emit_changed()

func emit_changed():
	changed.emit()

func from_current_toggled(toggled_on: bool) -> void:
	get_data_control(Type.PROPERTY, "from").editable = not toggled_on

func set_root(root: Node):
	get_data_control(Type.PROPERTY, "target").base_node = root
	get_data_control(Type.CALLBACK, "target").base_node = root
	get_data_control(Type.METHOD, "target").base_node = root
	get_data_control(Type.SUBTWEEN, "subtween").base_node = root
	get_data_control(Type.AWAIT, "target").base_node = root
