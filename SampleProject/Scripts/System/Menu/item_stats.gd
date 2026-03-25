extends Control
class_name ItemStats
@export var stats: VBoxContainer
@export var hbox_template: HBoxContainer
@export var attack_hbox_template: HBoxContainer
@export var defense_hbox_template: HBoxContainer
@export var stat_hbox_template: HBoxContainer
@export var element_hbox_template: HBoxContainer
@export var exit_label: Label
@export var animation: AnimationPlayer
var in_shop: bool = false
var can_open: bool = false:
	set(value):
		can_open = value
		if not can_open and visible:
			closeWindow()
var item: Variant:
	set(value):
		item = value
		if visible and item is Item:
			closeWindow()
			return
		if visible and item != null and item is not Item:
			resetStats()
			setStats()

enum CHILD {
	LABEL,
	VALUE
}

enum LabelColor {
	NORMAL,
	RED,
	BLUE,
	GRAY
}

const STATS = ["ATK", "DEF", "STR", "CON", "INT", "SYN", "RES", "LCK"]
const MISC_STATS = ["value", "max_quantity"]
const MISC_STAT_LABELS = ["ITEM_VALUE_LABEL", "ITEM_MAX_CAPACITY_LABEL"]
const STAT_LABELS = ["ATK_STAT_FULL", "DEF_STAT_FULL", "STR_STAT_FULL", "CON_STAT_FULL", "INT_STAT_FULL", "SYN_STAT_FULL", "MND_STAT_FULL", "LCK_STAT_FULL"]
const WEAPON_STATS = ["jump_cancel", "type"]
const WEAPON_STATS_LABELS = ["ITEM_LAND_CANCEL_LABEL", "ITEM_TYPE_LABEL"]
const WEAPON_TYPES = ["SWORD_TYPE_LABEL", "GREATSWORD_TYPE_LABEL", "AXE_TYPE_LABEL", "SPEAR_TYPE_LABEL", "KNUCKLES_TYPE_LABEL", "SPECIAL_TYPE_LABEL"]

func _ready() -> void:
	hbox_template.visible = false
	attack_hbox_template.visible = false
	defense_hbox_template.visible = false
	stat_hbox_template.visible = false
	element_hbox_template.visible = false
	visible = false
	
func _process(delta: float) -> void:
	if not animation.is_playing() and can_open and Input.is_action_just_pressed("guard"):
		if not visible:
			openWindow()
		if visible:
			closeWindow()

func openWindow() -> void:
	if item != null and item is not Item:
		setStats()
		if not visible:
			animation.play("play")
		
func closeWindow() -> void:
	if visible:
		animation.play("close")
		await animation.animation_finished
		resetStats()


func setStats() -> void:
	for i in range(0, STATS.size()):
		var item_stat: int = item[STATS[i]]
		var color: LabelColor = LabelColor.NORMAL
		if STATS[i] == "ATK":
			color = LabelColor.RED
		elif STATS[i] == "DEF":
			color = LabelColor.BLUE
		if item_stat != 0 or in_shop:
			createStatEntry(tr(STAT_LABELS[i]), item_stat, color, in_shop, i)
			
	if item is Weapon:
		createElementsEntry(tr("ATTRIBUTE_LABEL"), item.element)
		for i in range(0, WEAPON_STATS.size()):
			if WEAPON_STATS[i] == "jump_cancel":
				var item_stat: String = "YES_LABEL" if item[WEAPON_STATS[i]] else "NO_LABEL"
				createStatEntry(tr(WEAPON_STATS_LABELS[i]), item_stat)
			else:
				createStatEntry(tr(WEAPON_STATS_LABELS[i]), tr(WEAPON_TYPES[item[WEAPON_STATS[i]]]))
	
	if item is Headgear or item is Body or item is Legs or item is Accessory:
		createElementsEntry(tr("RESISTANCE_LABEL"), item.element)
	
	for i in range(0, MISC_STATS.size()):
		var item_stat: int = item[MISC_STATS[i]]
		if MISC_STATS[i] == "value" and not in_shop:
			item_stat *= ShopSell.SELL_WORTH_MULTIPLIER
		if not (MISC_STATS[i] == "value" and in_shop):
			createStatEntry(MISC_STAT_LABELS[i], item_stat)


func resetStats() -> void:
	for stat_entry in stats.get_children():
		if stat_entry not in [hbox_template, attack_hbox_template, defense_hbox_template, stat_hbox_template, element_hbox_template] and stat_entry is HBoxContainer:
			stat_entry.queue_free()

func createStatEntry(stat_name: String, value, hbox_color: LabelColor = LabelColor.GRAY, compare_with_equipped: bool = false, index: int = 0) -> void:
	var entry: HBoxContainer
	match hbox_color:
		LabelColor.NORMAL:
			entry = stat_hbox_template.duplicate()
		LabelColor.RED:
			entry = attack_hbox_template.duplicate()
		LabelColor.BLUE:
			entry = defense_hbox_template.duplicate()
		_:
			entry = hbox_template.duplicate()
	entry.get_child(CHILD.LABEL).text = stat_name
	if value is int and value < 0:
		entry.get_child(CHILD.VALUE).text = "[color=#cd5c5c]" + str(value) + "[/color]"
	else:
		entry.get_child(CHILD.VALUE).text = str(value)
	
	if compare_with_equipped:
		var equipped_value: int = 0
		var equipped_item = null
		var equipped_id: int = 0
		if item is Weapon:
			equipped_id = Global.player.stats.equipment[HectorStats.EQUIPMENT_SLOTS.WEAPON]-1
			if equipped_id >= 0:
				equipped_item = Global.player.stats.weapon_compendium[equipped_id]
		elif item is Headgear:
			equipped_id = Global.player.stats.equipment[HectorStats.EQUIPMENT_SLOTS.HEADGEAR]-1
			if equipped_id >= 0:
				equipped_item = Global.player.stats.headgear_compendium[equipped_id]
		elif item is Body:
			equipped_id = Global.player.stats.equipment[HectorStats.EQUIPMENT_SLOTS.BODY]-1
			if equipped_id >= 0:
				equipped_item = Global.player.stats.body_compendium[equipped_id]
		elif item is Legs:
			equipped_id = Global.player.stats.equipment[HectorStats.EQUIPMENT_SLOTS.LEGS]-1
			if equipped_id >= 0:
				equipped_item = Global.player.stats.legs_compendium[equipped_id]
		elif item is Accessory:
			equipped_id = Global.player.stats.equipment[HectorStats.EQUIPMENT_SLOTS.ACC_1]-1
			if equipped_id >= 0:
				equipped_item = Global.player.stats.accessory_compendium[equipped_id]
		if equipped_item:
			equipped_value = equipped_item[STATS[index]]
		var diff_value: int = value - equipped_value
		if diff_value > 0:
			entry.get_child(CHILD.VALUE).text += "[color=#0070ff] (+" + str(diff_value) + ")[/color]"
		elif diff_value < 0:
			entry.get_child(CHILD.VALUE).text += "[color=#cd5c5c] (" + str(diff_value) + ")[/color]"
		else:
			entry.get_child(CHILD.VALUE).text += " (" + str(diff_value) + ")"

	stats.add_child(entry)
	entry.visible = true

func createElementsEntry(entry_name: String, elements: Array[Global.Attribute]) -> void:
	if elements.size() == 0:
		return
	var entry: HBoxContainer = element_hbox_template.duplicate()
	entry.get_child(CHILD.LABEL).text = entry_name
	for i in range(elements.size()-1, -1, -1):
		var icon: TextureRect = TextureRect.new()
		icon.custom_minimum_size.x = 32
		icon.texture = Global.game.element_icons[elements[i]-1]
		entry.get_child(CHILD.VALUE).add_child(icon)
	stats.add_child(entry)
	entry.visible = true
