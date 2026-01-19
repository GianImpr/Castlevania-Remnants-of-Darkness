extends Control
class_name Shop

@export var initial_screen: Control
@export var buy_screen: ShopBuy
@export var sell_screen: ShopSell
@export var description_panel: PanelContainer
@export var description_icon: TextureRect
@export var description_text: Label
@export var animation: AnimationPlayer
@export var default_button: Button
@export var sound: PolyphonicMenuAudio
@export var julia_voice: PolyphonicMenuAudio
static var displayed_gold: int
static var AVAILABLE_ITEM_COLOR: Color = Color.WHITE
static var SELECTED_ITEM_COLOR: Color = Color.YELLOW
static var UNAVAILABLE_ITEM_COLOR: Color = Color(0.5, 0.5, 0.5)
static var can_open: bool = false
static var is_closed: bool = true

func _ready():
	initial_screen.process_mode = Node.PROCESS_MODE_DISABLED
	buy_screen.process_mode = Node.PROCESS_MODE_DISABLED
	sell_screen.process_mode = Node.PROCESS_MODE_DISABLED
	for button: Button in initial_screen.get_child(0).get_children():
		button.focus_entered.connect(func(): sound.play_sound_effect_from_library("cursor"))
		
func _process(delta: float) -> void:
	if can_open or true and Input.is_action_just_pressed("ui_up") and is_closed:
		startShop()
	if Input.is_action_just_pressed("ui_cancel") and initial_screen.process_mode == Node.PROCESS_MODE_ALWAYS  and not animation.is_playing():
		closeShop()

### Opens the initial shop screen.
func startShop() -> void:
	is_closed = false
	displayed_gold = Global.player.stats.Stats["GOLD"]
	Global.player.freeze()
	Global.screen = Global.ScreenType.SHOP
	julia_voice.play_sound_effect_from_library(["welcome", "come_on_in"].pick_random())
	initial_screen.process_mode = Node.PROCESS_MODE_ALWAYS
	description_text.text = tr("JULIA_WELCOME")
	animation.play("shop_start")
	await animation.animation_finished
	default_button.grab_focus()
	
### Opens the buy screen of the shop.
func openBuyMenu() -> void:
	julia_voice.play_sound_effect_from_library("today")
	animation.play("hide_initial")
	await animation.animation_finished
	initial_screen.process_mode = Node.PROCESS_MODE_DISABLED
	buy_screen.initializeBuyScreen()
	buy_screen.process_mode = Node.PROCESS_MODE_ALWAYS
	buy_screen.animation.play("show")

### Opens the sell screen of the shop.
func openSellMenu() -> void:
	julia_voice.play_sound_effect_from_library("today")
	animation.play("hide_initial")
	await animation.animation_finished
	initial_screen.process_mode = Node.PROCESS_MODE_DISABLED
	sell_screen.initializeSellScreen()
	sell_screen.process_mode = Node.PROCESS_MODE_ALWAYS
	sell_screen.animation.play("show")

### Closes the shop screen, returning to the game.
func closeShop() -> void:
	julia_voice.play_sound_effect_from_library("come_back")
	animation.play_backwards("shop_start")
	await animation.animation_finished
	Global.screen = Global.ScreenType.NONE
	initial_screen.process_mode = PROCESS_MODE_DISABLED
	get_viewport().gui_release_focus()
	Global.player.unfreeze()
	is_closed = true



func _on_buy_pressed() -> void:
	if animation.is_playing():
		return
	
	sound.play_sound_effect_from_library("confirm")
	openBuyMenu()


func _on_sell_pressed() -> void:
	if animation.is_playing():
		return
	
	sound.play_sound_effect_from_library("confirm")
	openSellMenu()
