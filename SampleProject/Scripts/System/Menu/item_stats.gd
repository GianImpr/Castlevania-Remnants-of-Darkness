extends Control
class_name ItemStats
@export var stats: VBoxContainer
@export var hbox_template: HBoxContainer
@export var attack_hbox_template: HBoxContainer
@export var defense_hbox_template: HBoxContainer
@export var stat_hbox_template: HBoxContainer
@export var exit_label: Label
@export var animation: AnimationPlayer
var can_open: bool = false:
	set(value):
		can_open = value
		if not can_open and visible:
			closeWindow()
var item: Variant:
	set(value):
		item = value
		if visible and item != null:
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
const MISC_STAT_LABELS = ["Value", "Can hold up to max"]
const STAT_LABELS = ["ATK_STAT_FULL", "DEF_STAT_FULL", "STR_STAT_FULL", "CON_STAT_FULL", "INT_STAT_FULL", "SYN_STAT_FULL", "MND_STAT_FULL", "LCK_STAT_FULL"]
const WEAPON_STATS = ["jump_cancel", "type"]
const WEAPON_STATS_LABELS = ["Allows land cancel", "Weapon type"]
const WEAPON_TYPES = ["Sword", "Greatsword", "Axe", "Spear", "Knuckles", "Special"]

func _ready() -> void:
	hbox_template.visible = false
	attack_hbox_template.visible = false
	defense_hbox_template.visible = false
	stat_hbox_template.visible = false
	visible = false
	
func _process(delta: float) -> void:
	if not animation.is_playing() and can_open and Input.is_action_just_pressed("guard"):
		if not visible:
			openWindow()
		if visible:
			closeWindow()

func openWindow() -> void:
	if item != null:
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
		if item_stat > 0:
			createStatEntry(tr(STAT_LABELS[i]), item_stat, false, color)
			
	if item is Weapon:
		for i in range(0, WEAPON_STATS.size()):
			if WEAPON_STATS[i] == "jump_cancel":
				var item_stat: String = "YES_LABEL" if item[WEAPON_STATS[i]] else "NO_LABEL"
				createStatEntry(WEAPON_STATS_LABELS[i], item_stat, true)
			else:
				createStatEntry(WEAPON_STATS_LABELS[i], WEAPON_TYPES[item[WEAPON_STATS[i]]], true)
				
	for i in range(0, MISC_STATS.size()):
		var item_stat: int = item[MISC_STATS[i]]
		if MISC_STATS[i] == "value":
			item_stat *= ShopSell.SELL_WORTH_MULTIPLIER
		createStatEntry(MISC_STAT_LABELS[i], item_stat)


func resetStats() -> void:
	for stat_entry in stats.get_children():
		if stat_entry not in [hbox_template, attack_hbox_template, defense_hbox_template, stat_hbox_template] and stat_entry is HBoxContainer:
			stat_entry.queue_free()

func createStatEntry(stat_name: String, value, text_font: bool = false, hbox_color: LabelColor = LabelColor.GRAY) -> void:
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
	entry.get_child(CHILD.VALUE).text = str(value)
	if text_font:
		var new_font: FontFile = FontFile.new()
		new_font.load_dynamic_font("res://assets/sprites/Font/McMillen.ttf")
		(entry.get_child(CHILD.VALUE) as Label).add_theme_font_override("font", new_font)
	stats.add_child(entry)
	entry.visible = true

func createElementsEntry(entry_name: String, elements: Global.Attribute) -> void:
	pass
