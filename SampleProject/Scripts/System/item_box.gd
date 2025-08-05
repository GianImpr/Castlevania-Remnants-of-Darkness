extends Control
class_name ItemBox
@export var label: Label
@export var timer: Timer
@export var textures: Array[CompressedTexture2D]

enum Type {
	BLUE,
	ORANGE,
	PURPLE,
	RED
}

func _ready() -> void:
	visible = false
	Global.item_box = self

func changeColor(type) -> void:
	var stylebox = StyleBoxTexture.new()
	stylebox.draw_center = true
	stylebox.texture = textures[type]
	stylebox.texture_margin_left = 16
	stylebox.texture_margin_right = 16
	stylebox.texture_margin_top = 4
	stylebox.content_margin_bottom = 4
	get_child(0).get_child(0).set("theme_override_styles/panel", stylebox)

func _on_timer_timeout() -> void:
	visible = false
