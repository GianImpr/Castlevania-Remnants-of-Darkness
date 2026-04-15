extends MenuState
class_name InvSummon

@export var id_panel: VBoxContainer
@export var buttons: SummonButtons
@export var send_back_button: InventoryButton
@export var id_entry_template: HBoxContainer
var first_button: InventoryButton

enum EntryChildID {
	NAME = 0,
	LEVEL = 2,
	BAR = 4,
	HEARTS = 5,
	DOWN = 6,
	EVO = 8
}

func _ready() -> void:
	id_panel.remove_child(id_entry_template)

func enter():
	animation.play_backwards("change")
	if Global.player.innocent_devil != null:
		Global.player.innocent_devil.updateStatsInEntry()
	updateInnocentDevils()
	buttons.setButtons()
	first_button.grab_focus()

func exit():
	deleteInnocentDevilList()
	animation.play("change")

func Update(delta: float):
	if Input.is_action_just_pressed("ui_cancel"):
		Transitioned.emit(self, "menu")
	
func Physics_Update(delta: float):
	pass
	
func updateInnocentDevils() -> void:
	id_panel.remove_child(send_back_button)
	var should_grab_focus: bool = true
	for devil: InnocentDevilEntry in Global.player.innocent_devil_pocket:
		var entry: HBoxContainer = id_entry_template.duplicate()
		entry.get_child(EntryChildID.NAME).text = devil.Name
		if should_grab_focus:
			first_button = entry.get_child(EntryChildID.NAME)
			should_grab_focus = false
		entry.get_child(EntryChildID.LEVEL).text = str(devil.Stats["LV"])
		var heart_bar: TextureProgressBar = entry.get_child(EntryChildID.BAR).get_child(0)
		heart_bar.value = float(devil.Stats["Hearts"])/devil.Stats["MHearts"]*heart_bar.max_value
		entry.get_child(EntryChildID.HEARTS).text = "%3d" % devil.Stats["Hearts"] + "/%3d" % devil.Stats["MHearts"]
		entry.get_child(EntryChildID.DOWN).modulate = Color.WHITE if not devil.is_alive else Color.TRANSPARENT
		entry.get_child(EntryChildID.EVO).text = "ON" if devil.allow_evo_crystals else "OFF"
		if Global.player.innocent_devil and devil.Name == Global.player.innocent_devil.id_name:
			entry.get_child(EntryChildID.NAME).disabled = true
		id_panel.add_child(entry)
	send_back_button.disabled = Global.player.innocent_devil == null
	id_panel.add_child(send_back_button)

func deleteInnocentDevilList() -> void:
	for entry in id_panel.get_children():
		if entry != id_entry_template and entry is HBoxContainer:
			entry.queue_free()
