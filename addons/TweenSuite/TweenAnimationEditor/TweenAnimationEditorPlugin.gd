@tool
extends EditorPlugin

var editor: EditorDock

func _enter_tree() -> void:
	editor = preload("./TweenAnimationEditorBase.tscn").instantiate()
	add_dock(editor)
	editor.close()
	scene_changed.connect(editor.update_root.unbind(1))

func _exit_tree() -> void:
	remove_dock(editor)
	editor.queue_free()

func _handles(object: Object) -> bool:
	if object is TweenNode:
		editor.set_node(object)
		return object.animation != null
	
	return object is TweenAnimation

func _edit(object: Object) -> void:
	if object is TweenNode:
		editor.edit(object.animation)
	else:
		editor.edit(object)

func _make_visible(visible: bool) -> void:
	if visible:
		editor.make_visible()
	else:
		editor.close()

func _apply_changes() -> void:
	editor.save_data()
