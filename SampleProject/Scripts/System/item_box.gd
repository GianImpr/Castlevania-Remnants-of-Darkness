extends Control
class_name ItemBox
@export var label: Label
@export var icon: TextureRect
@export var animation: AnimationPlayer
@export var textures: Array[CompressedTexture2D]
@export var margin_container: MarginContainer
@export var vbox_container: VBoxContainer

enum Type {
	BLUE,
	ORANGE,
	PURPLE,
	RED
}

func _ready() -> void:
	margin_container.visible = false
	Global.item_box = self

func changeColor(type) -> void:
	var stylebox = StyleBoxTexture.new()
	stylebox.draw_center = true
	stylebox.texture = textures[type]
	stylebox.texture_margin_left = 20
	stylebox.texture_margin_right = 20
	stylebox.texture_margin_top = 4
	stylebox.content_margin_bottom = 4
	margin_container.get_child(0).set("theme_override_styles/panel", stylebox)

func addEntry(item_name: String, item_type: Type, item_icon: Texture2D) -> void:
	if margin_container.visible:
		var new_entry: MarginContainer = margin_container.duplicate()
		_setBoxText(new_entry, item_name)
		_setBoxIcon(new_entry, item_icon)
		_setBoxColor(new_entry, item_type)
		_playBoxAnimation(new_entry)
		vbox_container.add_child(new_entry)
	else:
		label.text = item_name
		icon.texture = item_icon
		changeColor(item_type)
		margin_container.visible = true
		_playBoxAnimation(margin_container)
	
func deleteTopEntry() -> void:
	if vbox_container.get_child_count() > 1:
		margin_container = vbox_container.get_child(1)
		label = margin_container.get_child(0).get_child(0).get_child(1)
		icon = margin_container.get_child(0).get_child(0).get_child(0)
		animation = margin_container.get_child(1)
		vbox_container.get_child(0).queue_free()
	else:
		margin_container.visible = false

func _setBoxText(container: MarginContainer, text: String) -> void:
	var box_label: Label = container.get_child(0).get_child(0).get_child(1)
	box_label.text = text
	
func _setBoxIcon(container: MarginContainer, item_icon: Texture2D) -> void:
	var box_icon: TextureRect = container.get_child(0).get_child(0).get_child(0)
	box_icon.texture = item_icon

func _setBoxColor(container: MarginContainer, item_type: Type) -> void:
	var panel: PanelContainer = container.get_child(0)
	var stylebox = StyleBoxTexture.new()
	stylebox.draw_center = true
	stylebox.texture = textures[item_type]
	stylebox.texture_margin_left = 20
	stylebox.texture_margin_right = 20
	stylebox.texture_margin_top = 4
	stylebox.content_margin_bottom = 4
	panel.set("theme_override_styles/panel", stylebox)

func _playBoxAnimation(container: MarginContainer) -> void:
	var container_animation: AnimationPlayer = container.get_child(1)
	var container_hbox: HBoxContainer = container.get_child(0).get_child(0)
	var size_tween: Tween = get_tree().create_tween()
	const SIZE_TWEEN_DURATION: float = 0.2
	const EMPTY_CONTAINER_SIZE_X: float = 40
	const CONTAINER_DURATION: float = 2.8
	var original_size_x: float
	
	for child in container_hbox.get_children():
		original_size_x += child.get_combined_minimum_size().x
	original_size_x += (container_hbox.get_children().size() - 1) * container_hbox.get_theme_constant("separation")
	original_size_x += 44
	
	container_animation.play("show")
	size_tween.tween_property(container, "custom_maximum_size:x", original_size_x, SIZE_TWEEN_DURATION).from(EMPTY_CONTAINER_SIZE_X)
	await get_tree().create_timer(CONTAINER_DURATION, false).timeout
	size_tween = get_tree().create_tween()
	size_tween.tween_property(container, "custom_maximum_size:x", EMPTY_CONTAINER_SIZE_X, SIZE_TWEEN_DURATION)
