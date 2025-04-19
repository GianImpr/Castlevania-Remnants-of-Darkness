extends Control
@export var animation: AnimationPlayer
@export var game: PackedScene
@export var save_label: Label
@export var difficulty_label: Label
var can_load: bool = false

func _ready() -> void:
	var SAVE_PATH = "user://slot1.save"
	can_load = FileAccess.file_exists(SAVE_PATH)
	save_label.visible = can_load
	print_orphan_nodes()
	if can_load:
		const SaveManager = preload("res://addons/MetroidvaniaSystem/Template/Scripts/SaveManager.gd")
		var save_manager := SaveManager.new()
		if not save_manager.load_from_text(SAVE_PATH):
			save_label.text = "COULD NOT LOAD SAVE DATA"
			return
		# Assign loaded values.
		var stats = save_manager.get_value("stats")
		save_label.text = save_label.text + "\nLV " + str(stats.Stats["LV"]) + " HP " + str(stats.Stats["MHP"])
		stats.play_time.free()
		stats.free()

func _process(delta: float) -> void:
	if not animation.is_playing():
		if Input.is_action_just_pressed("menu"):
			animation.play("disappear")
			Global.load_data = false
		if Input.is_action_just_pressed("map") and can_load:
			animation.play("disappear")
			Global.load_data = true
		if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("move_right"):
			Global.crazy_mode = not Global.crazy_mode
			if Global.crazy_mode:
				difficulty_label.text = "DIFFICULTY\nCRAZY"
			else:
				difficulty_label.text = "DIFFICULTY\nNORMAL"

func startGame():
	get_tree().change_scene_to_packed(game)
