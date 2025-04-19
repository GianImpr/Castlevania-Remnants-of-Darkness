extends Node
class_name InventoryMenu
@export var state_machine: MenuStateMachine
@export var equip_slots: EquipButtons
@export var reset_timer: Timer

func _ready() -> void:
	Global.inventory = self

func _process(delta: float) -> void:
	if Input.is_action_pressed("menu") and Input.is_action_pressed("map") and reset_timer.is_stopped():
		reset_timer.start()
		
	if Input.is_action_just_released("menu") or Input.is_action_just_released("map") and not reset_timer.is_stopped():
		reset_timer.stop()

	if Global.player != null and Global.player.stats.Stats["HP"] > 0:
		pauseMenu()
		
		
func resume():
	state_machine.current_state.Transitioned.emit(state_machine.current_state, "closed")
	
func pause():
	state_machine.current_state.Transitioned.emit(state_machine.current_state, "menu")
	Global.screen = Global.ScreenType.MENU
	
func pauseMenu():
	if Input.is_action_just_pressed("menu") and !get_tree().paused and not Global.player.state_machine.current_state is HectorSitDown  and Global.screen == Global.ScreenType.NONE:
		pause()
	elif Input.is_action_just_pressed("menu") and get_tree().paused and Global.screen == Global.ScreenType.MENU:
		resume()
		
func resumeGame():
	Global.screen = Global.ScreenType.NONE
	get_tree().paused = false
	
func pauseGame():
	get_tree().paused = true


func _on_reset_timer_timeout() -> void:
	Global.toTitleScreen()
