extends Control
class_name FullItemBox
@export var label: Label
@export var description: RichTextLabelWithButtons
@export var icon: TextureRect
@export var animation: AnimationPlayer
@export var textures: Array[CompressedTexture2D]
@export var panel_container: PanelContainer

enum Type {
	BLUE,
	ORANGE,
	PURPLE,
	RED
}

func _ready() -> void:
	Global.full_item_box = self
	
func _input(event: InputEvent) -> void:
	if Global.screen == Global.ScreenType.ITEM_BOX and event.is_action_pressed("jump", false) and not animation.is_playing():
		dismiss()
		restoreScreenModulate()

func activate(type: Type, item_name: String, item_description: String, item_icon: Texture2D) -> void:
	makeScreenDark()
	_setBoxIcon(item_icon)
	_setBoxText(item_name, item_description)
	_setBoxColor(type)
	get_tree().paused = true
	Global.screen = Global.ScreenType.ITEM_BOX
	animation.play("show")
	
func dismiss() -> void:
	animation.play_backwards("show")
	await animation.animation_finished
	Global.screen = Global.ScreenType.NONE
	get_tree().paused = false

func _setBoxColor(type: Type) -> void:
	var stylebox = StyleBoxTexture.new()
	stylebox.draw_center = true
	stylebox.texture = textures[type]
	stylebox.texture_margin_left = 16
	stylebox.texture_margin_right = 16
	stylebox.texture_margin_top = 4
	stylebox.content_margin_bottom = 4
	panel_container.set("theme_override_styles/panel", stylebox)

func _setBoxText(item_name: String, item_description: String) -> void:
	label.text = item_name
	description.text = item_description
	
func _setBoxIcon(item_icon: Texture2D) -> void:
	icon.texture = item_icon

func makeScreenDark() -> void:
	const DARK_TWEEN_DURATION: float = 0.2
	var darkening_tween: Tween
	darkening_tween = get_tree().create_tween()
	darkening_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	darkening_tween.tween_property(get_tree().current_scene, "modulate", Color.DIM_GRAY, DARK_TWEEN_DURATION)
	
func restoreScreenModulate() -> void:
	const NORMAL_LIGHT_DURATION: float = 0.2
	var darkening_tween: Tween
	darkening_tween = get_tree().create_tween()
	darkening_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	darkening_tween.tween_property(get_tree().current_scene, "modulate", Color.WHITE, NORMAL_LIGHT_DURATION)
