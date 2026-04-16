extends Menu
class_name SummonButtons

@export var id_skills: HBoxContainer
@export var evo_crystals: HBoxContainer
@export var ATK_label: Label
@export var INT_label: Label
@export var DEF_label: Label
@export var MND_label: Label
@export var evolution_label: Label
@export var send_back_button: InventoryButton
@export var devil_stats_panel: Control
@export var devil_image: TextureRect


func ready() -> void:
	pass

func on_button_pressed(which):
	sound.play_sound_effect_from_library("confirm")
	
	if which == send_back_button:
		Global.player.innocent_devil.dismiss()
	else:
		if Global.player.innocent_devil:
			Global.player.innocent_devil.queue_free()
		var devil_to_summon: InnocentDevilEntry = Global.player.innocent_devil_pocket[which.get_parent().get_index()]
		Global.player.innocent_devil = devil_to_summon.innocent_devil_scene.instantiate()
		Global.player.get_parent().add_child(Global.player.innocent_devil)
		devil_to_summon.applyStats(Global.player.innocent_devil)
		Global.player.innocent_devil_scene = devil_to_summon.innocent_devil_scene
		Global.player.innocent_devil.summon()

	
	
	if get_tree().paused and Global.screen == Global.ScreenType.MENU:
		get_viewport().gui_release_focus()
		Global.inventory.resume()

func on_focused(which) -> void:
	super(which)
	if which == send_back_button:
		devil_stats_panel.visible = false
		return
		
	var index: int = which.get_parent().get_index()
	for icon in id_skills.get_children():
		icon.queue_free()
	var devil: InnocentDevilEntry = Global.player.innocent_devil_pocket[index]
	ATK_label.text = str(devil.Stats["ATK"])
	DEF_label.text = str(devil.Stats["DEF"])
	INT_label.text = str(devil.Stats["INT"])
	MND_label.text = str(devil.Stats["MND"])
	evolution_label.text = devil.evolution_name
	devil_image.texture = devil.image
	for i in range(1,9,2):
		evo_crystals.get_child(i).text = str(devil.evo_crystals[i/2])
	for skill: IDSkill in devil.skills:
		if skill.unlocked:
			var icon: TextureRect = TextureRect.new()
			icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			icon.custom_minimum_size = Vector2(32,32)
			icon.texture = skill.icon
			id_skills.add_child(icon)
	devil_stats_panel.visible = true
