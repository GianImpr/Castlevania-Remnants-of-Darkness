# This is the main script of the game. It manages the current map and some other stuff.
extends "res://addons/MetroidvaniaSystem/Template/Scripts/MetSysGame.gd"
class_name Game

const SaveManager = preload("res://addons/MetroidvaniaSystem/Template/Scripts/SaveManager.gd")
const SAVE_PATH = "user://slot1.save"
@export var animation: AnimationPlayer
var load_data: bool = false
@export var difficulty: Difficulty
@export var controller_scheme: ControllerScheme
@export var disable_lights: bool
@export var world_environment: WorldEnvironment
@export var touch_screen_enabled: bool = false

enum ControllerScheme {
	PLAYSTATION,
	XBOX,
	NINTENDO,
	KEYBOARD
}

enum Difficulty {
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

func _ready() -> void:
	if disable_lights:
		world_environment.queue_free()
		
	# Fade in when starting the game
	Global.fade_screen.modulate = Color(1,1,1,1)
	var fade_in_tween: Tween = get_tree().create_tween()
	fade_in_tween.tween_property(Global.fade_screen, "modulate", Color(1,1,1,0), 0.5)
	
	Global.game = self
	load_data = Global.load_data
	if Global.crazy_mode:
		difficulty = Difficulty.CRAZY
	else:
		difficulty = Difficulty.NORMAL
	# A trick for static object reference (before static vars were a thing).
	get_script().set_meta(&"singleton", self)
	# Make sure MetSys is in initial state.
	# Does not matter in this project, but normally this ensures that the game works correctly when you exit to menu and start again.
	MetSys.reset_state()
	# Assign player for MetSysGame.
	set_player($Player)
	
	if FileAccess.file_exists(SAVE_PATH) and load_data:
		load_game()
	else:
		# If no data exists, set empty one.
		MetSys.set_save_data()
	
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
	save_manager.set_value("equip_text", Global.inventory.equip_slots.saveEquipText())
	save_manager.set_value("equip_icons", Global.inventory.equip_slots.saveEquipIcons())
	save_manager.set_value("binding_swaps", Global.settings_node.joypad_binding_swaps)
	save_manager.set_value("settings", Global.settings_node.settings)
	save_manager.set_value("key_mapping", InputHelper.serialize_inputs_for_actions(Global.settings_node.Actions.values()))
	save_manager.set_value("difficulty", Global.game.difficulty)
	if player.sprite.weapon != null:
		save_manager.set_value("weapon", player.sprite.weapon.scene_file_path)
	save_manager.save_as_text(SAVE_PATH)

func reset_map_starting_coords():
	$UI/MapWindow.reset_starting_coords()

func init_room():
	MetSys.get_current_room_instance().adjust_camera_limits($Player/Camera2D)
	player.on_enter()

func load_game():
	# If save data exists, load it using MetSys SaveManager.
	var save_manager := SaveManager.new()
	save_manager.load_from_text(SAVE_PATH)
	# Assign loaded values.
	var stats = save_manager.get_value("stats")
	var old_stats = player.stats
	player.remove_child(old_stats)
	old_stats.play_time.free()
	old_stats.free()
	player.add_child(stats)
	stats.add_child(stats.play_time)
	player.stats = stats
	player.position = Vector2(259, 287)
	generated_rooms.assign(save_manager.get_value("generated_rooms"))
	player.unlocked_magic = save_manager.get_value("unlocked_magic")
	player.innocent_devil_pocket = save_manager.get_value("innocent_devil_pocket")
	player.innocent_devil_scene = save_manager.get_value("innocent_devil_scene")
	player.summoned_innocent_devil_id = save_manager.get_value("current_innocent_devil")
	player.can_jump_cancel = save_manager.get_value("can_jump_cancel")
	player.can_crouch_attack = save_manager.get_value("can_crouch_attack")
	var equip_text = save_manager.get_value("equip_text")
	var equip_icons = save_manager.get_value("equip_icons")
	Global.inventory.equip_slots.setEquipTextAndIcons(equip_text, equip_icons)
	Global.settings_node.joypad_binding_swaps = save_manager.get_value("binding_swaps")
	Global.settings_node.settings = save_manager.get_value("settings")
	InputHelper.deserialize_inputs_for_actions(save_manager.get_value("key_mapping"))
	Global.game.difficulty = save_manager.get_value("difficulty")
	
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
