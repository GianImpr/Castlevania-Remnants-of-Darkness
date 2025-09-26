@tool
# This is the main script of the game. It manages the current map and some other stuff.
extends "res://addons/MetroidvaniaSystem/Template/Scripts/MetSysGame.gd"
class_name Game

const SaveManager = preload("res://addons/MetroidvaniaSystem/Template/Scripts/SaveManager.gd")
@export var animation: AnimationPlayer
var load_data: bool = false
@export var difficulty: Difficulty
@export var controller_scheme: ControllerScheme
@export var disable_lights: bool
@export var update_player_compendium: bool
@export var world_environment: WorldEnvironment
@export var touch_screen_enabled: bool = false

@export var weapon_compendium: Array[Weapon]
@export var item_compendium: ItemCompendium
@export var headgear_compendium: Array[Headgear]
@export var body_compendium: Array[Body]
@export var legs_compendium: Array[Legs]
@export var accessory_compendium: Array[Accessory]
@export var skill_compendium: Array[Skill]
@export var relic_compendium: Array[Relic]
@export var artifact_compendium: Array[Artifact]
@export var dialogue_compendium: Array
@export var enemy_compendium: Array[EnemyEntry]
@export var save_rooms: Array[Dictionary]

@export var element_icons: Array[CompressedTexture2D]

#These are only used when @tool scripts require information about compendiums.
#Since compendiums are built with the export tag, which isn't compatible with
#static vars, there is non-static and static compendiums.
static var weapon_compendium_static: Array[Weapon]
static var item_compendium_static: ItemCompendium
static var headgear_compendium_static: Array[Headgear]
static var body_compendium_static: Array[Body]
static var legs_compendium_static: Array[Legs]
static var accessory_compendium_static: Array[Accessory]
static var skill_compendium_static: Array[Skill]
static var relic_compendium_static: Array[Relic]
static var artifact_compendium_static: Array
static var enemy_compendium_static: Array[EnemyEntry]
static var enemy_data: Array[Dictionary]

@export_group("Debug nodes")
@export var compendium_to_print: Compendiums
@export var print_compendium: bool = false:
	set(value):
		generateEnumListFor(getCompendium(), getCompendiumProperty())

@export var check_enemy_compendium: bool = false:
	set(value):
		checkEnemyCompendium()
		
@export var print_enemy_names: bool = false:
	set(value):
		checkEnemyData()

@export var update_static_compendiums: bool = false:
	set(value):
		weapon_compendium_static = weapon_compendium
		item_compendium_static = item_compendium
		headgear_compendium_static = headgear_compendium
		body_compendium_static = body_compendium
		legs_compendium_static = legs_compendium
		accessory_compendium_static = accessory_compendium
		skill_compendium_static = skill_compendium
		relic_compendium_static = relic_compendium
		artifact_compendium_static = artifact_compendium
		enemy_compendium_static = enemy_compendium

enum Compendiums {
	item,
	weapon,
	head,
	body,
	legs,
	accessory,
	skill,
	relic
}


enum ControllerScheme {
	PLAYSTATION,
	XBOX,
	NINTENDO,
	KEYBOARD
}

enum Difficulty {
	SIMPLIFIED,
	NORMAL,
	CRAZY
}

# The game starts in this map. Note that it's scene name only, just like MetSys refers to rooms.
@export var starting_map: String

# Number of collected collectibles. Setting it also updates the counter.
var collectibles: int:
	set(count):
		collectibles = count
		%CollectibleCount.text = "%d/6" % count

# The coordinates of generated rooms. MetSys does not keep this list, so it needs to be done manually.
var generated_rooms: Array[Vector3i]
# The typical array of game events. It's supplementary to the storable objects.
var events: Array[String]
# For Custom Runner integration.
var custom_run: bool

func generateEnumListFor(compendium, property) -> void:
	print("enum ITEMS {")
	var item_name: String
	for item in compendium:
		item_name = item[property]
		item_name = item_name.replace(" ", "_")
		item_name = item_name.replace("'", "")
		item_name = item_name.to_upper()
		print("\t" + item_name + ",")
	print("}")

func initializeEnemyData() -> void:
	for i in range(0, enemy_compendium.size()):
		enemy_data.append(enemy_compendium[i].getStats())


func checkEnemyCompendium() -> bool:
	update_static_compendiums = true
	for i in range(0, enemy_compendium_static.size()):
		var enemy: EnemyEntry = enemy_compendium_static[i]
		if enemy.enemy_scene == null:
			printerr("Enemy is missing. Entry: " + str(i))
			return false
		if not "enemy_name" in enemy.enemy_scene._bundled["names"]:
			printerr("Enemy name is missing in entry: " + str(i))
			return false
			
	print("Enemy Compendium: Everything OK.")
	return true
	
func checkEnemyData() -> void:
	if checkEnemyCompendium():
		for k in range(0, enemy_compendium_static.size()):
			var info = enemy_compendium_static[k].enemy_scene.get_state()
			var stats: Dictionary
			
			for stat in EnemyEntry.Stats.values():
				stats[stat] = 0
				
			for i in range(0, info.get_node_count()):
				var cur_node_type = info.get_node_type(i)
				if cur_node_type == "Sprite2D":
					for j in range(0, info.get_node_property_count(i)):
						print(JSON.stringify(info.get_node_property_name(i, j), " "))
					

func getCompendium():
	match compendium_to_print:
		Compendiums.item:
			return item_compendium.Compendium
		Compendiums.body:
			return body_compendium
		Compendiums.weapon:
			return weapon_compendium
		Compendiums.head:
			return headgear_compendium
		Compendiums.legs:
			return legs_compendium
		Compendiums.relic:
			return relic_compendium
		Compendiums.skill:
			return skill_compendium
		Compendiums.accessory:
			return accessory_compendium
			
func getCompendiumProperty():
	match compendium_to_print:
		Compendiums.item:
			return "item_name"
		Compendiums.body:
			return "body_name"
		Compendiums.weapon:
			return "weapon_name"
		Compendiums.head:
			return "headgear_name"
		Compendiums.legs:
			return "legs_name"
		Compendiums.relic:
			return "relic_name"
		Compendiums.skill:
			return "skill_name"
		Compendiums.accessory:
			return "accessory_name"

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	else:
		if disable_lights:
			world_environment.queue_free()
		
		initializeEnemyData()
		
		# Fade in when starting the game
		Global.fade_screen.modulate = Color(1,1,1,1)
		var fade_in_tween: Tween = get_tree().create_tween()
		fade_in_tween.tween_property(Global.fade_screen, "modulate", Color(1,1,1,0), 0.5)
		
		Global.game = self
		load_data = Global.load_data
		# A trick for static object reference (before static vars were a thing).
		get_script().set_meta(&"singleton", self)
		# Make sure MetSys is in initial state.
		# Does not matter in this project, but normally this ensures that the game works correctly when you exit to menu and start again.
		MetSys.reset_state()
		# Assign player for MetSysGame.
		set_player($Player)
		
		if FileAccess.file_exists(Global.save_file_to_load) and load_data:
			load_game()
		else:
			# If no data exists, set empty one and set difficulty
			MetSys.set_save_data()
			difficulty = Global.new_game_difficulty
			Global.player.stats.file_name = Global.new_game_player_name
			for i in range(0, EquipMenu.quick_weapons.size()):
				EquipMenu.quick_weapons[i] = null
			player.stats.item_compendium = item_compendium
			player.stats.weapon_compendium = weapon_compendium
			player.stats.headgear_compendium = headgear_compendium
			player.stats.body_compendium = body_compendium
			player.stats.legs_compendium = legs_compendium
			player.stats.relic_compendium = relic_compendium
			player.stats.skill_compendium = skill_compendium
			player.stats.accessory_compendium = accessory_compendium
			player.stats.artifact_compendium = artifact_compendium
			player.stats.enemy_compendium = enemy_compendium

			
		#Will reset combine. Use only to synchronize player compendium with a new compendium.
		if update_player_compendium:
			player.stats.item_compendium = item_compendium
			player.stats.weapon_compendium = weapon_compendium
			player.stats.headgear_compendium = headgear_compendium
			player.stats.body_compendium = body_compendium
			player.stats.legs_compendium = legs_compendium
			player.stats.relic_compendium = relic_compendium
			player.stats.skill_compendium = skill_compendium
			player.stats.accessory_compendium = accessory_compendium
			player.stats.artifact_compendium = artifact_compendium
			player.stats.enemy_compendium = enemy_compendium

		
		# Initialize room when it changes.
		room_loaded.connect(init_room, CONNECT_DEFERRED)
		# Load the starting room.
		load_room(starting_map)
		
		# Add module for room transitions.
		add_module("RoomTransitions.gd")
		
		# Reset position tracking (feature specific to this project).
		await get_tree().physics_frame
		reset_map_starting_coords.call_deferred()


# Returns this node from anywhere.
static func get_singleton() -> Game:
	return (Game as Script).get_meta(&"singleton") as Game

# Save game using MetSys SaveManager.
func save_game():
	if player.innocent_devil != null:
		player.innocent_devil.updateStatsInEntry()
		
	var save_manager := SaveManager.new()
	save_manager.set_value("stats", player.stats)
	save_manager.set_value("generated_rooms", generated_rooms)
	save_manager.set_value("current_room", MetSys.get_current_room_name())
	save_manager.set_value("unlocked_magic", player.unlocked_magic)
	save_manager.set_value("innocent_devil_scene", player.innocent_devil_scene)
	save_manager.set_value("current_innocent_devil", player.summoned_innocent_devil_id-1)
	save_manager.set_value("innocent_devil_pocket", player.innocent_devil_pocket)
	save_manager.set_value("can_jump_cancel", player.can_jump_cancel)
	save_manager.set_value("can_crouch_attack", player.can_crouch_attack)
	save_manager.set_value("pocket_size", player.pocket_size)
	save_manager.set_value("equip_icons", Global.inventory.equip_slots.saveEquipIcons())
	save_manager.set_value("binding_swaps", Global.settings_node.joypad_binding_swaps)
	save_manager.set_value("settings", Global.settings_node.settings)
	save_manager.set_value("key_mapping", InputHelper.serialize_inputs_for_actions(Global.settings_node.Actions.values()))
	save_manager.set_value("difficulty", Global.game.difficulty)
	save_manager.set_value("quick_weapons", EquipMenu.serializeQuickWeapons())
	save_manager.set_value("file_name", Global.player.stats.file_name)
	save_manager.set_value("map_ratio", Global.player.stats.map_ratio)
	save_manager.set_value("position", Global.player.global_position)
	if player.sprite.weapon != null:
		save_manager.set_value("weapon", player.sprite.weapon.scene_file_path)
	save_manager.save_as_text(Global.save_destination)

func reset_map_starting_coords():
	$UI/MapWindow.reset_starting_coords()

func init_room():
	MetSys.get_current_room_instance().adjust_camera_limits($Player/Camera2D)
	player.on_enter()

func load_game():
	# If save data exists, load it using MetSys SaveManager.
	var save_manager := SaveManager.new()
	save_manager.load_from_text(Global.save_file_to_load)
	# Assign loaded values.
	var stats = save_manager.get_value("stats")
	var old_stats = player.stats
	player.remove_child(old_stats)
	old_stats.play_time.free()
	old_stats.free()
	player.add_child(stats)
	stats.add_child(stats.play_time)
	player.stats = stats
	generated_rooms.assign(save_manager.get_value("generated_rooms"))
	player.unlocked_magic = save_manager.get_value("unlocked_magic")
	player.innocent_devil_pocket = save_manager.get_value("innocent_devil_pocket")
	player.innocent_devil_scene = save_manager.get_value("innocent_devil_scene")
	player.summoned_innocent_devil_id = save_manager.get_value("current_innocent_devil")
	player.can_jump_cancel = save_manager.get_value("can_jump_cancel")
	player.can_crouch_attack = save_manager.get_value("can_crouch_attack")
	var equip_icons = save_manager.get_value("equip_icons")
	Global.inventory.equip_slots.setEquipIcons(equip_icons)
	Global.settings_node.joypad_binding_swaps = save_manager.get_value("binding_swaps")
	Global.settings_node.settings = save_manager.get_value("settings")
	EquipMenu.deserializeQuickWeapons(save_manager.get_value("quick_weapons"))
	InputHelper.deserialize_inputs_for_actions(save_manager.get_value("key_mapping"))
	Global.game.difficulty = save_manager.get_value("difficulty")
	Global.player.stats.file_name = save_manager.get_value("file_name")
	Global.player.stats.map_ratio = save_manager.get_value("map_ratio")
	if save_manager.get_value("position") != null:
		Global.player.global_position = save_manager.get_value("position") + Vector2(30, 0)
	else:
		player.position = Vector2(259, 287)
		
	if player.sprite.weapon != null:
		player.sprite.weapon.queue_free()
	
	if player.summoned_innocent_devil_id >= 0:
		if player.innocent_devil != null:
			player.innocent_devil.free()
		player.innocent_devil_scene = player.innocent_devil_pocket[player.summoned_innocent_devil_id].innocent_devil_scene
		player.innocent_devil = player.innocent_devil_scene.instantiate()
		player.innocent_devil_pocket[player.summoned_innocent_devil_id].applyStats(player.innocent_devil)
		player.get_parent().add_child(player.innocent_devil)
		player.innocent_devil.global_position = player.global_position + Vector2(75, -50)
	
	player.pocket_size = save_manager.get_value("pocket_size")
	var weapon_path = save_manager.get_value("weapon")
	if weapon_path != null:
		var weapon = load(weapon_path).instantiate()
		weapon.hitbox.player = player
		weapon.hitbox.sound = player.sound
		weapon.hitbox.state_machine = player.state_machine
		player.sprite.weapon = weapon
		player.add_child(player.sprite.weapon)
	
	if not custom_run:
		var loaded_starting_map: String = save_manager.get_value("current_room")
		if not loaded_starting_map.is_empty(): # Some compatibility problem.
			starting_map = loaded_starting_map
