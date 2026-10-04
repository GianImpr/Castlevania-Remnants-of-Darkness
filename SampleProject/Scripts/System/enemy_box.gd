extends Control
class_name EnemyBox
@export var label: Label
@export var timer: Timer
@export var textures: Array[CompressedTexture2D]
@export var animation: AnimationPlayer
var size_tween: Tween
var prev_text: String

func _ready() -> void:
	Global.enemy_box = self

func changeColor(type) -> void:
	var stylebox = StyleBoxTexture.new()
	stylebox.draw_center = true
	stylebox.texture = textures[type]
	stylebox.texture_margin_left = 20
	stylebox.texture_margin_right = 20
	stylebox.content_margin_bottom = 4
	get_child(0).set("theme_override_styles/panel", stylebox)
	
func playBoxAnimation() -> void:
	var container: MarginContainer = get_child(1)
	var container_panel: PanelContainer = container.get_child(0)
	
	if size_tween and size_tween.is_running():
		size_tween.kill()
		
		
	const SIZE_TWEEN_DURATION: float = 0.2
	const EMPTY_CONTAINER_SIZE_X: float = 40
	const CONTAINER_DURATION: float = 2.8
	var original_size_x: float
	
	for child in container_panel.get_children():
		original_size_x += child.get_combined_minimum_size().x
	original_size_x += (container_panel.get_children().size() - 1) * container_panel.get_theme_constant("separation")
	original_size_x += 44
	
	
	if label.text != prev_text or container.modulate != Color.WHITE:
		animation.play("show")
		animation.seek(0)
		prev_text = label.text
		size_tween = get_tree().create_tween()
		size_tween.tween_method(
			func(v): container_panel.custom_maximum_size.x = int(v),
			int(EMPTY_CONTAINER_SIZE_X), int(original_size_x), SIZE_TWEEN_DURATION
		)
		#size_tween.tween_property(container_panel, "custom_maximum_size:x", original_size_x, SIZE_TWEEN_DURATION).from(EMPTY_CONTAINER_SIZE_X)
		timer.start()
		
	await timer.timeout
	size_tween = get_tree().create_tween()
	size_tween.tween_method(
		func(v): container_panel.custom_maximum_size.x = int(v),
		int(original_size_x), int(EMPTY_CONTAINER_SIZE_X), SIZE_TWEEN_DURATION
	)
	#size_tween.tween_property(container_panel, "custom_maximum_size:x", EMPTY_CONTAINER_SIZE_X, SIZE_TWEEN_DURATION)
