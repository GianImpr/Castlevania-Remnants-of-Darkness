extends MenuButtons
class_name MenuSaveRoom
@export var animation: AnimationPlayer
@onready var chair_node = get_parent().get_parent().get_parent()
@export var saving_screen: SavingScreen
@export var warp_screen: WarpScreen
@export var default_button: InventoryButton
const stand_up_flag_id: int = 12
const stand_up_hint_time: float = 3
var stand_up_hint_text: String = tr("HINT_12")
var needs_to_choose = true

func _ready() -> void:
	super()
	
func resetState() -> void:
	saving_screen.process_mode = Node.PROCESS_MODE_DISABLED
	chair_node.opened_menu = true
	default_button.grab_focus()

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("circle") and needs_to_choose:
		_exitMenu()

func on_button_pressed(which):
	needs_to_choose = false
	match which.get_index():
		0:
			which.release_focus()
			_saveGame()
		1:
			_openWarpScreen()
		2:
			which.release_focus()
			_exitMenu()
	sound.play_sound_effect_from_library("confirm")

func _saveGame():
	closeWindow()
	await animation.animation_finished
	saving_screen.saved_with_success = false
	saving_screen.closing = false
	saving_screen.process_mode = Node.PROCESS_MODE_ALWAYS
	saving_screen.animation.play("appear")
	await saving_screen.finished
	if saving_screen.saved_with_success:
		chair_node.sound.play_sound_effect_from_library("activate")
		chair_node.animation.play("flash")
		await chair_node.animation.animation_finished
		chair_node.detect_hitbox.set_collision_mask_value(2, false)
		chair_node.can_sit = false
		if not Global.player.stats.hint_flags[stand_up_flag_id]:
			Global.tutorial_box.activate = true
			Global.tutorial_box.time = stand_up_hint_time
			Global.tutorial_box.text = stand_up_hint_text
			Global.player.stats.hint_flags[stand_up_flag_id] = true
	resumeGame()
	
func _openWarpScreen() -> void:
	closeWindow()
	await animation.animation_finished
	warp_screen.animation.play("appear")
	warp_screen.process_mode = Node.PROCESS_MODE_ALWAYS
	await warp_screen.finished
	if warp_screen.destination_selected != "":
		warp()
	else:
		resumeGame()


func warp():
	const NORMAL_POSITION: Vector2 = Vector2(232,282)
	const FLIPPED_POSITION: Vector2 = Vector2(726,282)
	const FINAL_WARP_COLOR: Color = Color(0.5, 1.5, 0, 0)
	const FINAL_SCALE: Vector2 = Vector2(0, 4)
	const POSITION_OFFSET: Vector2 = Vector2(0, -50)
	const TWEEN_DURATION: float = 1.5
	const DELAY: float = 1.2
	var warp_tween: Tween = get_tree().create_tween()
	var cur_position: Vector2
	var destination_flipped: bool = warp_screen.destination_flip

	if destination_flipped:
		cur_position = FLIPPED_POSITION
	else:
		cur_position = NORMAL_POSITION
	cur_position.y = Global.player.global_position.y
		
	chair_node.sound.play_sound_effect_from_library("activate")
	warp_tween.pause()
	warp_tween.set_parallel(true)
	warp_tween.tween_property(Global.player.sprite, "self_modulate", FINAL_WARP_COLOR, TWEEN_DURATION)
	warp_tween.tween_property(Global.player.sprite, "scale", FINAL_SCALE, TWEEN_DURATION)
	warp_tween.tween_property(Global.player.sprite, "position", position+POSITION_OFFSET, TWEEN_DURATION)
	get_tree().create_timer(DELAY).timeout.connect(func(): warp_tween.play())
	chair_node.animation.play("warp_flash")
	await chair_node.animation.animation_finished
	resumeGame()
	Global.player.facing_position = -1 if destination_flipped else 1
	Global.player.sprite.flip_h = destination_flipped
	Global.change_area.emit(warp_screen.destination_selected, cur_position)

	
func _exitMenu():
	get_viewport().gui_release_focus()
	closeWindow()
	await animation.animation_finished
	resumeGame()
	
	
func closeWindow():
	animation.play_backwards("appear_without_reset")
	
func resumeGame():
	chair_node.opened_menu = false
	get_parent().get_parent().process_mode = Node.PROCESS_MODE_DISABLED
