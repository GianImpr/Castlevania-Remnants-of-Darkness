extends MenuState
class_name InvBestiary

enum BestiaryScreen {
	LIST,
	PROFILE
}

enum DropLabel {
	COMMON,
	RARE
}

enum DropIndex {
	ICON,
	NAME,
	DROP_RATE
}

@export var button_glow: StyleBoxFlat
@export var enemy_list: GridContainer
@export_category("Bestiary Screens")
@export var encyclopedia: Control
@export var monster_profile: Control
@export_category("Enemy Profile Nodes")
@export var sprite: Sprite2D
@export var description: RichTextLabelWithButtons
@export var HP: Label
@export var LV: Label
@export var Name: Label
@export var stats: VBoxContainer
@export var killed: Label
@export var drops: VBoxContainer
@export var tolerances: HBoxContainer
@export var weaknesses: HBoxContainer
var stylebox_empty: StyleBoxFlat = StyleBoxFlat.new()

var current_screen: BestiaryScreen
var current_button_index: int = 0
const MINIMUM_BUTTON_SIZE: Vector2 = Vector2(308, 0)
const UNKNOWN_ENEMY_NAME: String = "? ? ?"
const UNKNOWN_DROP_NAME: String = "? ? ?"
const ABSENT_DROP_NAME: String = "- - -"

var transition_tween: Tween
const TWEEN_DURATION: float = 0.1

func enter():
	stylebox_empty.bg_color = Color.DARK_RED
	resetBestiaryMenu()
	animation.play_backwards("change")
	initializeEnemyList()
	default_button.grab_focus()

func exit():
	deleteEnemyList()
	animation.play("change")

func Update(delta: float):
	if Input.is_action_just_pressed("ui_cancel"):
		if current_screen == BestiaryScreen.LIST:
			Transitioned.emit(self, "menu")
		else:
			openEncyclopedia()
			enemy_list.get_child(current_button_index+1).grab_focus()
		
func Physics_Update(delta: float):
	pass
	
func initializeEnemyList() -> void:
	for i in range(0, Game.enemy_data.size()):
		var button: InventoryButton = InventoryButton.new()
		
		if wasBeaten(i):
			button.text = Game.enemy_data[i][EnemyEntry.Stats.NAME]
			button.disabled = false
		else:
			button.text = UNKNOWN_ENEMY_NAME
			button.disabled = true
			
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.custom_minimum_size = MINIMUM_BUTTON_SIZE
		button.flat = true
		button.desired_state = self
		button.add_theme_stylebox_override("normal", stylebox_empty)
		button.add_theme_stylebox_override("pressed", stylebox_empty)
		button.add_theme_stylebox_override("hover", stylebox_empty)
		button.add_theme_stylebox_override("disabled", stylebox_empty)
		button.add_theme_stylebox_override("focus", stylebox_empty)
		button.focus_entered.connect(on_focused.bind(button))
		button.pressed.connect(on_button_pressed.bind(button))
		enemy_list.add_child(button)
	default_button = enemy_list.get_child(1)

func deleteEnemyList() -> void:
	for button in enemy_list.get_children():
		if button is Button:
			button.queue_free()

func on_button_pressed(which) -> void:
	sound.play_sound_effect_from_library("confirm")
	which.release_focus()
	initMonsterProfile(current_button_index)
	openMonsterProfile()
	
func on_focused(which) -> void:
	sound.play_sound_effect_from_library("cursor")
	current_button_index = which.get_index()-1

func wasBeaten(enemy_id: int) -> bool:
	return Global.player.stats.enemy_compendium[enemy_id].killed > 0

func resetBestiaryMenu() -> void:
	current_screen = BestiaryScreen.LIST
	encyclopedia.modulate = Color.WHITE
	monster_profile.modulate = Color.TRANSPARENT
	
func openMonsterProfile() -> void:
	current_screen = BestiaryScreen.PROFILE
	transition_tween = get_tree().create_tween()
	transition_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	transition_tween.tween_property(encyclopedia, "modulate", Color.TRANSPARENT, TWEEN_DURATION)
	transition_tween.tween_property(monster_profile, "modulate", Color.WHITE, TWEEN_DURATION)
	
func openEncyclopedia() -> void:
	current_screen = BestiaryScreen.LIST
	transition_tween = get_tree().create_tween()
	transition_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	transition_tween.tween_property(monster_profile, "modulate", Color.TRANSPARENT, TWEEN_DURATION)
	transition_tween.tween_property(encyclopedia, "modulate", Color.WHITE, TWEEN_DURATION)

func initMonsterProfile(index: int) -> void:
	var enemy_stats: Dictionary = Game.enemy_data[index]
	var enemy_flags: EnemyEntry
	const STAT_VALUE_INDEX: int = 1
	const STAT_KEYS = [EnemyEntry.Stats.ATK, EnemyEntry.Stats.DEF, EnemyEntry.Stats.MND, EnemyEntry.Stats.EXP]
	
	if Game.get_singleton().update_player_compendium:
		enemy_flags = Game.get_singleton().enemy_compendium[index]
	else:
		enemy_flags = Global.player.stats.enemy_compendium[index]
	

	HP.text = str(enemy_stats[EnemyEntry.Stats.HP])
	LV.text = str(int(enemy_stats[EnemyEntry.Stats.LV] + EnemyStats.CRAZY_MODE_LEVEL_BOOST * int(Global.game.difficulty == Game.Difficulty.CRAZY)))
	Name.text = str(enemy_stats[EnemyEntry.Stats.NAME])

	description.text = str(enemy_stats[EnemyEntry.Stats.DESCRIPTION])
	sprite.texture = enemy_flags.enemy_icon
	
	for i in range(0, stats.get_child_count()):
		var current_line: HBoxContainer = stats.get_child(i)
		if Global.game.difficulty == Game.Difficulty.CRAZY:
			_printStat(enemy_stats, STAT_KEYS, i, STAT_VALUE_INDEX, current_line, EnemyStats.CRAZY_MODE_STAT_MULTIPLIER)
		elif Global.game.difficulty == Game.Difficulty.SIMPLIFIED:
			_printStat(enemy_stats, STAT_KEYS, i, STAT_VALUE_INDEX, current_line, EnemyStats.SIMPLIFIED_MODE_STAT_MULTIPLIER)
		else:
			current_line.get_child(STAT_VALUE_INDEX).text = str(enemy_stats[STAT_KEYS[i]])
		
	killed.text = str(enemy_flags.killed)
	
	initializeElementalTable(weaknesses, enemy_stats[EnemyEntry.Stats.WEAKNESSES])
	initializeElementalTable(tolerances, enemy_stats[EnemyEntry.Stats.TOLERANCES])
	initializeDropLabel(enemy_stats[EnemyEntry.Stats.COMMON_DROP_ID], DropLabel.COMMON, enemy_stats[EnemyEntry.Stats.COMMON_DROP_RATE], enemy_flags.common_drop_revealed)
	initializeDropLabel(enemy_stats[EnemyEntry.Stats.RARE_DROP_ID], DropLabel.RARE, enemy_stats[EnemyEntry.Stats.RARE_DROP_RATE], enemy_flags.rare_drop_revealed)

func _printStat(enemy_stats, STAT_KEYS, i, STAT_VALUE_INDEX, current_line, stat_multiplier) -> void:
	if STAT_KEYS[i] == EnemyEntry.Stats.ATK:
		current_line.get_child(STAT_VALUE_INDEX).text = str(int((enemy_stats[STAT_KEYS[i]] + int(LV.text)*int(Global.game.difficulty == Game.Difficulty.CRAZY)) * stat_multiplier))
	elif STAT_KEYS[i] != EnemyEntry.Stats.EXP:
		current_line.get_child(STAT_VALUE_INDEX).text = str(int(enemy_stats[STAT_KEYS[i]] * stat_multiplier))
	else:
		current_line.get_child(STAT_VALUE_INDEX).text = str(int(enemy_stats[STAT_KEYS[i]]))

func initializeDropLabel(drop_id: int, drop_label: DropLabel, drop_rate: float, revealed: bool) -> void:
	var item: Item = Global.player.stats.searchItemInCompendium(drop_id, Global.player.stats.item_compendium.Compendium)
	var drop_data: HBoxContainer = drops.get_child(drop_label)
	if item == null:
		drop_data.get_child(DropIndex.ICON).texture = null
		drop_data.get_child(DropIndex.NAME).text = ABSENT_DROP_NAME
		drop_data.get_child(DropIndex.DROP_RATE).text = ""
		return
		
	if revealed:
		drop_data.get_child(DropIndex.ICON).texture = item.icon
		drop_data.get_child(DropIndex.NAME).text = tr(item.item_name)
	else:
		drop_data.get_child(DropIndex.ICON).texture = null
		drop_data.get_child(DropIndex.NAME).text = UNKNOWN_DROP_NAME
	
	drop_data.get_child(DropIndex.DROP_RATE).text = "%2.2f%%" % (EnemyStats.calculateDropRate(drop_rate)*100)

func initializeElementalTable(table: HBoxContainer, elements) -> void:
	const ICON_SIZE := Vector2(32, 32)
	for child in table.get_children():
		child.queue_free()
		
	if elements is int:
		return
	
	for element in elements:
		var icon := TextureRect.new()
		icon.texture = Game.get_singleton().element_icons[element-1]
		icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH
		icon.custom_minimum_size = ICON_SIZE
		table.add_child(icon)
