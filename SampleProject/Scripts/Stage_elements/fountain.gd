extends Node2D
class_name Fountain
@export var yellow_door: CombatDoor
@export var green_door: CombatDoor
@export var blue_door: CombatDoor
@export var orange_door: CombatDoor
@export var stones: HBoxContainer
@export var moving_platform: Node2D
@export var first_event_flag: int
@export var area: Area2D
var can_interact: bool = false
const camera_offset_list: Array[Vector2] = [Vector2(432, 421), Vector2(528, 858), Vector2(528,421), Vector2(528,421)]
var doors: Array[CombatDoor] = [yellow_door, green_door, blue_door, orange_door]

enum Events {
	YELLOW,
	GREEN,
	BLUE,
	ORANGE
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area.area_entered.connect(_on_area_entered)
	area.area_exited.connect(_on_area_exited)
	
	if Global.player.stats.event_flags[first_event_flag]:
		enablePlatform()
		
	updateStoneVisibility()
	openAlreadyUnlockedDoors()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("up_arrow") and can_interact:
		_triggerCurrentEvent()
		
	if Global.player.stats.event_flags[first_event_flag+Events.size()-1]:
		area.monitoring = false


func _on_area_entered(area_2d: Area2D) -> void:
	Global.player.tap_up.appear()
	can_interact = true

func _on_area_exited(area_2d: Area2D) -> void:
	Global.player.tap_up.dismiss()
	can_interact = false

func _triggerCurrentEvent() -> void:
	for i in range(0, Events.size()):
		if not Global.player.stats.event_flags[first_event_flag+i]:
			checkStone(i)
			

func updateStoneVisibility() -> void:
	for i in range(0, Events.size()):
		if Global.player.stats.event_flags[first_event_flag+i]:
			stones.get_child(i).self_modulate = Color.WHITE
		else:
			stones.get_child(i).self_modulate = Color.BLACK

func checkStone(stone_to_check: int) -> void:
	const MESSAGE_DURATION: float = 2
	const SUCCESS_MESSAGE: String = "GEMSTONE_INSERTED"
	const FAILED_MESSAGE: String = "GEMSTONE_REQUIRED"
	const items_to_check: Array[Item.Items] = [Item.Items.YELLOW_GEMSTONE, Item.Items.GREEN_GEMSTONE, Item.Items.BLUE_GEMSTONE, Item.Items.ORANGE_GEMSTONE]
	if Global.player.stats.hasItem(items_to_check[stone_to_check]):
		Global.player.stats.event_flags[first_event_flag+stone_to_check] = true
		Global.tutorial_box.popup(tr(SUCCESS_MESSAGE), MESSAGE_DURATION)
		updateStoneVisibility()
		openDoor(stone_to_check)
	else:
		if not Global.tutorial_box.isActive():
			Global.tutorial_box.popup(tr(FAILED_MESSAGE), MESSAGE_DURATION)

func openDoor(door_index: int) -> void:
	doors = [yellow_door, green_door, blue_door, orange_door]
	var door_to_open: CombatDoor = doors[door_index]
	const INITIAL_WAIT_SECONDS: float = 1
	const CAMERA_MOVE_DURATION: float = 2
	Global.player.freeze()
	can_interact = false
	await get_tree().create_timer(INITIAL_WAIT_SECONDS).timeout
	Global.camera.moveCamera(camera_offset_list[door_index]-Global.player.global_position, CAMERA_MOVE_DURATION)
	await Global.camera.camera_moved
	door_to_open._on_detection_area_area_entered(null)
	enablePlatform()
	await Global.camera.camera_moved_back
	Global.player.unfreeze()


func openAlreadyUnlockedDoors() -> void:
	doors = [yellow_door, green_door, blue_door, orange_door]
	for i in range(0, Events.size()):
		if Global.player.stats.event_flags[first_event_flag+i]:
			doors[i].get_parent().queue_free()

func enablePlatform() -> void:
	var platform_sprite_animation: AnimationPlayer = moving_platform.get_child(0).get_child(0).get_child(0)
	var platform_movement_animation: AnimationPlayer = moving_platform.get_child(1)
	platform_movement_animation.play("move")
	platform_sprite_animation.play("spinning")
