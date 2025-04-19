extends MenuState
class_name InvSummon

@export var empty_ID_bar: GradientTexture2D
@export var fill_ID_bar: GradientTexture2D
@export var id_panel: VBoxContainer
@export var buttons: SummonButtons

func enter():
	animation.play_backwards("change")
	if Global.player.innocent_devil != null:
		Global.player.innocent_devil.updateStatsInEntry()
	updateInnocentDevils()
	buttons.setButtons()
	default_button.grab_focus()

func exit():
	deleteInnocentDevilList()
	animation.play("change")

func Update(delta: float):
	if Input.is_action_just_pressed("ui_cancel"):
		Transitioned.emit(self, "menu")
	
func Physics_Update(delta: float):
	pass
	
func updateInnocentDevils() -> void:
	for devil in Global.player.innocent_devil_pocket:
		var id_entry: HBoxContainer = HBoxContainer.new()
		var id_name: Label = Label.new()
		var id_level: Label = Label.new()
		var id_bar: TextureProgressBar = TextureProgressBar.new()
		var id_hearts: Label = Label.new()
		var blankspace_filler: String
		var button: InventoryButton = InventoryButton.new()
		button.text = " "
		button.flat = true
		button.state_machine = buttons.state_machine
		id_name.text = devil.Name
		while (id_name.text.length() + blankspace_filler.length() < 14):
			blankspace_filler += " "
		id_name.text += blankspace_filler
		id_level.text = "LV.%02d" % devil.Stats["LV"]
		id_bar.texture_under = empty_ID_bar
		id_bar.texture_progress = fill_ID_bar
		id_bar.value = float(devil.Stats["Hearts"])/devil.Stats["MHearts"]*id_bar.max_value
		id_bar.size_flags_vertical = Control.SIZE_SHRINK_END
		id_hearts.text = " %3d" % devil.Stats["Hearts"] + "/" + "%3d" % devil.Stats["MHearts"]
		id_entry.add_child(id_name)
		id_entry.add_child(id_level)
		id_entry.add_child(id_bar)
		id_entry.add_child(id_hearts)
		id_panel.add_child(id_entry)
		buttons.add_child(button)
	var send_back_label: Label = Label.new()
	var send_back_button: InventoryButton = InventoryButton.new()
	send_back_button.state_machine = buttons.state_machine
	send_back_label.text = "Send back"
	send_back_button.text = " "
	send_back_button.flat = true
	id_panel.add_child(send_back_label)
	buttons.add_child(send_back_button)
	default_button = buttons.get_child(0)

func deleteInnocentDevilList() -> void:
	for entry in id_panel.get_children():
		entry.queue_free()
	for button in buttons.get_children():
		button.queue_free()
