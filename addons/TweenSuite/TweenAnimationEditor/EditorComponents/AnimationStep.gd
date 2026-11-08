@tool
extends Control

@onready var tweeners: BoxContainer = %Tweeners
@onready var add_tweener_button: MenuButton = %AddTweener

signal deleted

func _ready() -> void:
	if is_part_of_edited_scene():
		return
	
	update_header()
	
	for style: StringName in [&"normal", &"pressed", &"hover", &"disabled", &"focus"]:
		add_tweener_button.add_theme_stylebox_override(style, get_theme_stylebox(style, &"OptionButton"))
	
	add_theme_stylebox_override(&"panel", get_theme_stylebox(&"panel", &"TreeSecondary"))

func connect_signals(editor: Control):
	add_tweener_button.get_popup().id_pressed.connect(editor.on_new_tweener.bind(self))
	tree_exited.connect(editor.update_step_headers)
	deleted.connect(editor.push_data_delayed)

func add_tweener(tweener: Control):
	tweeners.add_child(tweener)
	tweener.tree_exited.connect(update_tweener_headers)

func update_header():
	%HeaderLabel.format(get_index())

func update_tweener_headers():
	for tweener in tweeners.get_children():
		tweener.update_id()

func delete_me() -> void:
	deleted.emit()
	queue_free()
