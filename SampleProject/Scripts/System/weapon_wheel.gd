extends Control
class_name WeaponWheel
@export var animation: AnimationPlayer
@export var cursor_animation: AnimationPlayer
@export var cursor_coordinates: Array[Vector2]
@export var cursor_sprite: Sprite2D
@export var weapon_icons: Node2D
@export var sound: PolyphonicMenuAudio

var cursor_position: Position
const BRIGHT_CURSOR_COLOR: Color = Color(1, 1, 1)
const DARK_CURSOR_COLOR: Color = Color(0.5, 0.5, 0.5)

static var quickWeaponSwap: Callable

enum Position {
	UP,
	RIGHT,
	DOWN,
	LEFT,
	ABSENT
}

func open() -> void:
	sound.play_sound_effect_from_library("toggle")
	cursor_sprite.visible = false
	cursor_position = Position.ABSENT
	animation.play("appear")
	
func close() -> void:
	sound.play_sound_effect_from_library("toggle")
	cursor_sprite.visible = false
	cursor_position = Position.ABSENT
	animation.play_backwards("appear")
	
func _input(event: InputEvent) -> void:
	const RSTICK_ACTIONS: Array[String] = ["rstick_up", "next_skill", "rstick_down", "previous_skill"]
	if Global.screen != Global.ScreenType.WHEEL:
		return
		
	for i in range(0, RSTICK_ACTIONS.size()):
		if event.is_action_pressed(RSTICK_ACTIONS[i]) and cursor_position != Position.values()[i]:
			cursor_sprite.visible = true
			cursor_position = Position.values()[i]
			cursor_sprite.position = cursor_coordinates[cursor_position]
			if EquipMenu.quick_weapons[i] != null:
				sound.play_sound_effect_from_library("select_full")
				cursor_animation.queue("idle")
				cursor_sprite.self_modulate = BRIGHT_CURSOR_COLOR
			else:
				sound.play_sound_effect_from_library("select_empty")
				cursor_animation.clear_queue()
				cursor_sprite.self_modulate = DARK_CURSOR_COLOR
			cursor_animation.play("select")
			break


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("weapon_swap") and Global.screen == Global.ScreenType.NONE:
		if Global.player.isAttacking():
			return
		updateIcons()
		get_tree().paused = true
		open()
		Global.screen = Global.ScreenType.WHEEL
		
	if Input.is_action_just_released("weapon_swap") and Global.screen == Global.ScreenType.WHEEL:
		get_tree().paused = false
		if cursor_position != Position.ABSENT:
			quickWeaponSwap.call(cursor_position)
		close()
		Global.screen = Global.ScreenType.NONE

func updateIcons() -> void:
	for i in range(0, EquipMenu.quick_weapons.size()):
		if EquipMenu.quick_weapons[i] != null:
			weapon_icons.get_child(i).texture = EquipMenu.quick_weapons[i].icon
		else:
			weapon_icons.get_child(i).texture = null
