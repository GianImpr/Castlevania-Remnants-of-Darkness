@tool
extends RigidBody2D
class_name PickUp
@export var type: ItemType:
	set(value):
		type = value
		updateItemInformation()
@export var id: int:
	set(value):
		id = value
		updateItemInformation()
		
@export var current_item_name: String
@export var sprite: Sprite2D
@export var idle_timer: Timer
@export var flash_timer: Timer
@export var animation: AnimationPlayer
@export var sound: PolyphonicMenuAudio
@export var item_full_scene: PackedScene
@export var get_next_flag: bool:
	set(value):
		pickup_flag = next_flag_to_use
		next_flag_to_use += 1
@export var pickup_flag: int
@export var boost_message: PackedScene
@export var auto_equip: bool = false
var compendium: Array[Dictionary]

static var next_flag_to_use: int

static var change_equipment: Callable

enum ItemType {
	ITEM,
	WEAPON,
	ARTIFACT,
	RELIC,
	HEADGEAR,
	BODY,
	LEGS,
	ACCESSORY,
	SKILL
}

const SlotNames = {
	WEAPON = "weapon",
	ARTIFACT = "artifact",
	RELIC = "relic",
	HEAD = "head",
	BODY = "body",
	LEGS = "legs",
	ACCESSORY = "acc1"
}

func _ready() -> void:
	if Engine.is_editor_hint():
		return
		
	if Global.player.stats.picked_items[pickup_flag]:
		queue_free()
	if type != ItemType.SKILL and type != ItemType.ARTIFACT and type != ItemType.RELIC:
		animation.play("idle")
	else:
		animation.play("idle_relic")
		flash_timer.stop()
		idle_timer.stop()
		
	sprite.texture = Global.player.stats.searchItemInCompendium(id, getCompendium())["icon"]

func _on_idle_duration_timeout() -> void:
	flash_timer.start()
	animation.play("flashing")

func _on_flash_duration_timeout() -> void:
	idle_timer.start()
	animation.play("idle")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if Global.player.stats.findItem(id, getInventory()) >= Global.player.stats.searchItemInCompendium(id, getCompendium())["max_quantity"]:
		var item_full_label = item_full_scene.instantiate()
		add_child(item_full_label)
		return
		
	idle_timer.stop()
	flash_timer.stop()
	if not auto_equip:
		Global.player.stats.addItem(id, getInventory())
	else:
		var old_item_id: int = Global.player.stats.equipment[determineSlot()]
		Global.player.stats.equipment[determineSlot()] = id
		
		if old_item_id != 0:
			Global.player.stats.addItem(old_item_id, getInventory())
		var item = Global.player.stats.searchItemInCompendium(id, getCompendium())
		if change_equipment != null:
			change_equipment.bind(type-1, item[getItemName()], item["icon"]).call()
			#Still need the logic to update player stats
	if type == ItemType.ITEM:
		sound.play_sound_effect_from_library("item")
		Global.item_box.changeColor(ItemBox.Type.BLUE)
	elif type == ItemType.SKILL or type == ItemType.ARTIFACT or type == ItemType.RELIC:
		var popup = boost_message.instantiate()
		popup.get_child(0).frame = 3
		Global.player.sprite.enable_glow = true
		Global.player.add_child(popup)
		if type == ItemType.SKILL:
			Global.item_box.changeColor(ItemBox.Type.ORANGE)
		elif type == ItemType.RELIC:
			Global.item_box.changeColor(ItemBox.Type.PURPLE)
			if not Global.player.unlocked_magic:
				Global.player.unlockMagic()
		else:
			Global.item_box.changeColor(ItemBox.Type.RED)
	else:
		sound.play_sound_effect_from_library("equip")
		Global.item_box.changeColor(0)
	Global.item_box.visible = true
	Global.item_box.label.text = Global.player.stats.searchItemInCompendium(id, getCompendium())[getItemName()]
	Global.item_box.timer.start()
	animation.play("picked")
	
func getCompendium():
	match type:
		ItemType.ITEM:
			return Global.player.stats.item_compendium.Compendium
		ItemType.WEAPON:
			return Global.player.stats.weapon_compendium
		ItemType.RELIC:
			return Global.player.stats.relic_compendium
		ItemType.HEADGEAR:
			return Global.player.stats.headgear_compendium
		ItemType.BODY:
			return Global.player.stats.body_compendium
		ItemType.LEGS:
			return Global.player.stats.legs_compendium
		ItemType.ACCESSORY:
			return Global.player.stats.accessory_compendium
		ItemType.SKILL:
			return Global.player.stats.skill_compendium
		ItemType.ARTIFACT:
			return Global.player.stats.artifact_compendium
		_:
			return null
			
func getInventory() -> Array[Dictionary]:
	var lists = Global.player.stats
	match type:
		ItemType.ITEM:
			return lists.item_inventory
		ItemType.WEAPON:
			return lists.weapon_inventory
		ItemType.ARTIFACT:
			return lists.artifact_inventory
		ItemType.RELIC:
			return lists.relic_inventory
		ItemType.HEADGEAR:
			return lists.head_inventory
		ItemType.BODY:
			return lists.body_inventory
		ItemType.LEGS:
			return lists.legs_inventory
		ItemType.ACCESSORY:
			return lists.acc_inventory
		ItemType.SKILL:
			return lists.skill_inventory
		_:
			return []

			
func getItemName() -> String:
	var prefixes = ["item_", "weapon_", "artifact_", "relic_", "headgear_", "body_", "legs_", "accessory_", "skill_"]
	return prefixes[type] + "name"
	
func setFlag() -> void:
	if pickup_flag > 0:
		Global.player.stats.picked_items[pickup_flag] = true

func determineSlot() -> String:
	match type:
		ItemType.WEAPON:
			return SlotNames.WEAPON
		ItemType.ARTIFACT:
			return SlotNames.ARTIFACT
		ItemType.RELIC:
			return SlotNames.RELIC
		ItemType.HEADGEAR:
			return SlotNames.HEAD
		ItemType.BODY:
			return SlotNames.BODY
		ItemType.LEGS:
			return SlotNames.LEGS
		ItemType.ACCESSORY:
			return SlotNames.ACCESSORY
		_:
			printerr("Unexpected auto-equip slot")
			return ""

func updateItemInformation():
	if not Engine.is_editor_hint():
		return
	var cur_compendium: Array
	var name_property: String
	match type:
		ItemType.ITEM:
			cur_compendium = Game.item_compendium_static.Compendium
			name_property = "item_name"
		ItemType.WEAPON:
			cur_compendium = Game.weapon_compendium_static
			name_property = "weapon_name"
		ItemType.HEADGEAR:
			cur_compendium = Game.headgear_compendium_static
			name_property = "headgear_name"
		ItemType.RELIC:
			cur_compendium = Game.relic_compendium_static
			name_property = "relic_name"
		ItemType.ARTIFACT:
			cur_compendium = Game.artifact_compendium_static
			name_property = "artifact_name"
		ItemType.BODY:
			cur_compendium = Game.body_compendium_static
			name_property = "body_name"
		ItemType.LEGS:
			cur_compendium = Game.legs_compendium_static
			name_property = "legs_name"
		ItemType.ACCESSORY:
			cur_compendium = Game.accessory_compendium_static
			name_property = "accessory_name"
		ItemType.SKILL:
			cur_compendium = Game.skill_compendium_static
			name_property = "skill_name"
	if id < 1 or id > cur_compendium.size():
		current_item_name = "<null>"
		return
	var item = cur_compendium[id-1]
	current_item_name = item[name_property]
	if sprite != null:
		sprite.texture = item.icon
