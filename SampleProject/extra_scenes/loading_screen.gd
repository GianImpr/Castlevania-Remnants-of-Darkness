extends Control
class_name LoadingScreen
@export var game_scene: PackedScene
@export var save_slots: VBoxContainer
@export var displayed_slot_data: Control
@export var animation: AnimationPlayer
@export var sound: PolyphonicMenuAudio

@export var hector_portrait: CompressedTexture2D

const AVAILABLE_SLOT_COLOR: Color = Color.WHITE
const SELECTED_SLOT_COLOR: Color = Color.YELLOW
const CLOSED_SLOT_COLOR: Color = Color(0.31, 0.31, 0.31)
const CORRUPTED_SLOT_COLOR: Color = Color.INDIAN_RED
const INITIAL_SAVE_PATH: String = "user://slot"
const SAVE_FILE_EXTENSION: String = ".save"
const SAVE_MANAGER_RESOURCE = preload("res://addons/MetroidvaniaSystem/Template/Scripts/SaveManager.gd")
const FILE_NAME_INDEX: int = 1
const CHECKPOINT_SAVE_NAME: String = "checkpoint"
const NO_SLOT: int = -1
var start_new_game: bool = false

const FILE_DATA = {
	STATUS = "STATUS",
	NAME = "NAME",
	HP = "HP",
	LV = "LV",
	GOLD = "GOLD",
	TIME = "TIME",
	MAP_RATIO = "MAP_RATIO",
	CURRENT_MAP = "CURRENT_MAP",
	CHARACTER = "CHARACTER"
}

enum FILE_DATA_STATUS {
	EMPTY,
	INVALID,
	AVAILABLE
}

var current_file_data: Array[Dictionary]
var focused_slot: int = 0

@export var file_HP: Label
@export var file_LV: Label
@export var file_GOLD: Label
@export var file_playtime: Label
@export var file_map_completion: Label
@export var file_current_stage: Label
@export var file_character: TextureRect
@export var file_name: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_file_data.resize(save_slots.get_child_count())
	initializeSaveSlots()
	highlightFocusedSlotAndUpdateOldOne(NO_SLOT)
	displaySlotData()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if animation.is_playing():
		return 
		
	checkInput()
	
func checkInput() -> void:
	if Input.is_action_just_pressed("ui_down"):
		var prev_slot: int = focused_slot
		focused_slot = posmod((focused_slot+1), save_slots.get_child_count())
		highlightFocusedSlotAndUpdateOldOne(prev_slot)
		sound.play_sound_effect_from_library("cursor")
		save_slots.get_child(focused_slot).get_child(FILE_NAME_INDEX).grab_focus()
		displaySlotData()

	elif Input.is_action_just_pressed("ui_up"):
		var prev_slot: int  = focused_slot
		focused_slot = posmod((focused_slot-1), save_slots.get_child_count())
		highlightFocusedSlotAndUpdateOldOne(prev_slot)
		sound.play_sound_effect_from_library("cursor")
		save_slots.get_child(focused_slot).get_child(FILE_NAME_INDEX).grab_focus()
		displaySlotData()
		
	elif Input.is_action_just_pressed("ui_accept"):
		onSlotPressed()
			
	elif Input.is_action_just_pressed("ui_cancel"):
		exitScreen()

func initializeSaveSlots() -> void:
	for i in range(0, save_slots.get_child_count()):
		var current_slot: HBoxContainer = save_slots.get_child(i)
		var save_file_path: String = INITIAL_SAVE_PATH + str(i) + SAVE_FILE_EXTENSION
		if FileAccess.file_exists(save_file_path):
			var save_manager = SAVE_MANAGER_RESOURCE.new()
			if not save_manager.load_from_text(save_file_path, false):
				current_slot.modulate = CORRUPTED_SLOT_COLOR
				current_slot.get_child(FILE_NAME_INDEX).text = "Invalid"
				current_file_data[i][FILE_DATA.STATUS] = FILE_DATA_STATUS.INVALID
			else:
				current_slot.modulate = AVAILABLE_SLOT_COLOR
				loadSlotData(i, save_manager)
				current_slot.get_child(FILE_NAME_INDEX).text = current_file_data[i][FILE_DATA.NAME]
		else:
			current_slot.modulate = CLOSED_SLOT_COLOR
			current_file_data[i][FILE_DATA.STATUS] = FILE_DATA_STATUS.EMPTY
			current_slot.get_child(FILE_NAME_INDEX).text = "Empty"

func loadSlotData(slot_number: int, save_manager) -> void:
	var stats: HectorStats = save_manager.get_value("stats")
	current_file_data[slot_number][FILE_DATA.STATUS] = FILE_DATA_STATUS.AVAILABLE
	current_file_data[slot_number][FILE_DATA.NAME] = stats.file_name
	current_file_data[slot_number][FILE_DATA.HP] = stats.Stats["MHP"]
	current_file_data[slot_number][FILE_DATA.LV] = stats.Stats["LV"]
	current_file_data[slot_number][FILE_DATA.GOLD] = stats.Stats["GOLD"]
	current_file_data[slot_number][FILE_DATA.TIME] = stats.play_time._to_string()
	current_file_data[slot_number][FILE_DATA.CURRENT_MAP] = tr(stats.current_area)
	current_file_data[slot_number][FILE_DATA.MAP_RATIO] = stats.map_ratio
	stats.play_time.free()
	stats.free()
	
func displaySlotData() -> void:
	if containsData(focused_slot):
		var slot = current_file_data[focused_slot]
		displayed_slot_data.visible = true
		file_HP.text = str(slot[FILE_DATA.HP])
		file_LV.text = str(slot[FILE_DATA.LV])
		if slot[FILE_DATA.NAME]:
			file_name.text = slot[FILE_DATA.NAME]
		else:
			file_name.text = "Unnamed"
		file_GOLD.text = str(slot[FILE_DATA.GOLD])
		file_playtime.text = slot[FILE_DATA.TIME]
		file_map_completion.text = slot[FILE_DATA.MAP_RATIO]
		file_current_stage.text = slot[FILE_DATA.CURRENT_MAP]
		#file_character.texture = hector_portrait
	else:
		displayed_slot_data.visible = false
		
		

func containsData(slot_number: int) -> bool:
	return current_file_data[slot_number][FILE_DATA.STATUS] == FILE_DATA_STATUS.AVAILABLE

func highlightFocusedSlotAndUpdateOldOne(prev_slot: int) -> void:
	save_slots.get_child(focused_slot).modulate = SELECTED_SLOT_COLOR
	
	if prev_slot == NO_SLOT:
		return
	
	var old_slot: HBoxContainer = save_slots.get_child(prev_slot)
	match current_file_data[prev_slot][FILE_DATA.STATUS]:
		FILE_DATA_STATUS.AVAILABLE:
			old_slot.modulate = AVAILABLE_SLOT_COLOR
		FILE_DATA_STATUS.EMPTY:
			old_slot.modulate = CLOSED_SLOT_COLOR
		FILE_DATA_STATUS.INVALID:
			old_slot.modulate = CORRUPTED_SLOT_COLOR
			
func startGame():
	get_tree().change_scene_to_packed(game_scene)
	
func titleScreen():
	Global.toTitleScreen()
	
func onSlotPressed():
	if containsData(focused_slot):
		Global.save_file_to_load = INITIAL_SAVE_PATH + str(focused_slot) + SAVE_FILE_EXTENSION
		animation.play("disappear")
		sound.play_sound_effect_from_library("confirm")
	else:
		sound.play_sound_effect_from_library("denied")
		
func exitScreen():
	animation.play("disappear_to_title")
	
static func loadBattleCheckpoint() -> void:
	var destination = INITIAL_SAVE_PATH + CHECKPOINT_SAVE_NAME + SAVE_FILE_EXTENSION
	Global.load_data = true
	if Global.save_file_to_load != destination:
		Global.save_destination = Global.save_file_to_load
	Global.save_file_to_load = destination
	
static func isloadingBattleCheckpoint() -> bool:
	var checkpoint_name = INITIAL_SAVE_PATH + CHECKPOINT_SAVE_NAME + SAVE_FILE_EXTENSION
	return Global.save_file_to_load == checkpoint_name

	#var SAVE_PATH = "user://slot1.save"
	#can_load = FileAccess.file_exists(SAVE_PATH)
	#if can_load:
		#const SaveManager = preload("res://addons/MetroidvaniaSystem/Template/Scripts/SaveManager.gd")
		#var save_manager := SaveManager.new()
		#if not save_manager.load_from_text(SAVE_PATH):
			#save_label.text = "COULD NOT LOAD SAVE DATA"
			#return
		## Assign loaded values.
		#var stats = save_manager.get_value("stats")
		#save_label.text = save_label.text + "\nLV " + str(stats.Stats["LV"]) + " HP " + str(stats.Stats["MHP"])
		#stats.play_time.free()
		#stats.free()
