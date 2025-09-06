extends CanvasLayer
class_name InGameMenu
@export var default_button: InventoryButton
@export var warp_button: InventoryButton
@export var animation: AnimationPlayer

func _ready() -> void:
	default_button.grab_focus()
	var can_warp: bool = Global.player.stats.findItem(Skill.Skills.WARP_MEDALLION, Global.player.stats.skill_inventory)
	warp_button.disabled = not can_warp
	if can_warp:
		warp_button.text = tr("TELEPORT_GAME_BUTTON")
	else:
		warp_button.text = "? ? ?"
