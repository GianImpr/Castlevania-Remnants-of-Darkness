extends Menu
class_name EquipSlots
@export var equip_list: EquipMenu
@export var quantity_list: GridContainer

func _ready() -> void:
	for button in get_children():
		if button is InventoryButton:
			button.pressed.connect(button_pressed.bind(button))
			button.focus_entered.connect(focused.bind(button))
			button["theme_override_styles/focus"] = button_glow


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel") and $"../../..".open:
		$"../../..".animation.play("change")
		$"../../..".get_parent().animation.play_backwards("change")
		$"../../..".get_parent().buttons.get_child(2).grab_focus()
		print($"../../..".get_parent().buttons.get_child(2).get_name())
		
func button_pressed(which):
	print(which.get_index())
	match which.get_index():
		0:
			equip_list.initList(Global.player.stats.weapon_inventory)
		1:
			equip_list.initList(Global.player.stats.artifact_inventory)
		2:
			equip_list.initList(Global.player.stats.relic_inventory)
		3:
			equip_list.initList(Global.player.stats.head_inventory)
		4:
			equip_list.initList(Global.player.stats.body_inventory)
		5:
			equip_list.initList(Global.player.stats.legs_inventory)
		6:
			equip_list.initList(Global.player.stats.acc_inventory)
		7:
			equip_list.initList(Global.player.stats.acc_inventory)
			
	sound.play_sound_effect_from_library("confirm")
	equip_list.get_child(0).grab_focus()
	print(equip_list.get_child(0).get_name())
	
func focused(button):
	$"../../../".labels.get_child(1).text = button.get_name()
	sound.play_sound_effect_from_library("cursor")
	
func trigger_focus():
	get_child(0).grab_focus()


func _on_glow_timer_timeout() -> void:
	for child in get_children():
		button_glow.bg_color = Color(glow_intensity, 0, 0)
