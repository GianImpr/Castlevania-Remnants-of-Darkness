extends Control
class_name WeaponWheel
@export var animation: AnimationPlayer
@export var cursor_animation: AnimationPlayer
@export var cursor_coordinates: Array[Vector2]
@export var cursor_sprite: Sprite2D
@export var slot_icons: Node2D
@export var sound: PolyphonicMenuAudio
var delay_equip: bool = false
var delayed_position: int = 0
var relic_wheel: bool = false
@export var wheel_textures: Array[CompressedTexture2D]
@export var wheel_sprite: Sprite2D
@export var switch_label: RichTextLabelWithButtons

var cursor_position: Position
const BRIGHT_CURSOR_COLOR: Color = Color(1, 1, 1)
const DARK_CURSOR_COLOR: Color = Color(0.5, 0.5, 0.5)

static var quickWeaponSwap: Callable
static var quickRelicSwap: Callable

enum Position {
	UP,
	RIGHT,
	DOWN,
	LEFT,
	ABSENT
}

enum WheelTexture {
	WEAPON,
	RELIC
}

func open() -> void:
	sound.play_sound_effect_from_library("toggle")
	cursor_sprite.visible = false
	cursor_position = Position.ABSENT
	animation.play("appear")
	
func close() -> void:
	sound.play_sound_effect_from_library("toggle")
	relic_wheel = false
	cursor_sprite.visible = false
	cursor_position = Position.ABSENT
	animation.play_backwards("appear")
	
func switchToRelics() -> void:
	open()
	animation.seek(0)
	relic_wheel = true
	
func switchToWeapons() -> void:
	open()
	animation.seek(0)
	relic_wheel = false
	
func _input(event: InputEvent) -> void:
	const RSTICK_ACTIONS: Array[String] = ["rstick_up", "next_skill", "rstick_down", "previous_skill"]
	if Global.screen != Global.ScreenType.WHEEL:
		return
		
	for i in range(0, RSTICK_ACTIONS.size()):
		if event.is_action_pressed(RSTICK_ACTIONS[i]) and cursor_position != Position.values()[i]:
			cursor_sprite.visible = true
			cursor_position = Position.values()[i]
			cursor_sprite.position = cursor_coordinates[cursor_position]
			if relic_wheel:
				if EquipMenu.quick_relics[i] != null:
					sound.play_sound_effect_from_library("select_full")
					cursor_animation.queue("idle")
					cursor_sprite.self_modulate = BRIGHT_CURSOR_COLOR
				else:
					sound.play_sound_effect_from_library("select_empty")
					cursor_animation.clear_queue()
					cursor_sprite.self_modulate = DARK_CURSOR_COLOR
			else:
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
	if Input.is_action_just_pressed("l2") and Global.screen == Global.ScreenType.NONE:
		updateWeaponIcons()
		relic_wheel = false
		updateWheelTexture()
		get_tree().paused = true
		open()
		Global.screen = Global.ScreenType.WHEEL
		
	if Input.is_action_just_pressed("guard") and Global.screen == Global.ScreenType.WHEEL:
		if relic_wheel:
			switchToWeapons()
			updateWeaponIcons()
		else:
			switchToRelics()
			updateRelicIcons()
		updateWheelTexture()
		
	if Input.is_action_just_released("l2") and Global.screen == Global.ScreenType.WHEEL:
		get_tree().paused = false
		if cursor_position != Position.ABSENT and not Global.player.isAttacking():
			if relic_wheel:
				quickRelicSwap.call(cursor_position)
			else:
				quickWeaponSwap.call(cursor_position)
		elif cursor_position != Position.ABSENT:
			if not relic_wheel:
				delay_equip = true
				delayed_position = cursor_position
			else:
				quickRelicSwap.call(cursor_position)
		close()
		Global.screen = Global.ScreenType.NONE
		
	if delay_equip and not Global.player.isAttacking():
		delay_equip = false
		quickWeaponSwap.call(delayed_position)


func updateWeaponIcons() -> void:
	for i in range(0, EquipMenu.quick_weapons.size()):
		if EquipMenu.quick_weapons[i] != null:
			slot_icons.get_child(i).texture = EquipMenu.quick_weapons[i].icon
		else:
			slot_icons.get_child(i).texture = null

func updateRelicIcons() -> void:
	for i in range(0, EquipMenu.quick_relics.size()):
		if EquipMenu.quick_relics[i] != null:
			slot_icons.get_child(i).texture = EquipMenu.quick_relics[i].icon
		else:
			slot_icons.get_child(i).texture = null

func updateWheelTexture() -> void:
	if relic_wheel:
		wheel_sprite.texture = wheel_textures[WheelTexture.RELIC]
		switch_label.new_text = \
		"""[center] [[R1]]
[font_size=32]%s[/font_size]
[/center]
		""" % tr("RELIC_EQUIP_LABEL")
	else:
		wheel_sprite.texture = wheel_textures[WheelTexture.WEAPON]
		switch_label.new_text = \
		"""[center] [[R1]]
[font_size=32]%s[/font_size]
[/center]
		""" % tr("WEAPON_EQUIP_LABEL")
