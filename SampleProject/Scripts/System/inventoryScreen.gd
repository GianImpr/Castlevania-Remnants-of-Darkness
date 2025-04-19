extends Control

@export var labels: Control
@export var buttons: VBoxContainer
@export var default_button: InventoryButton
@export var equip_menu: Control
@export var animation: AnimationPlayer
var resume_game: bool = true
enum screen {
	MAIN = 0,
	EQUIP = 1
}
var state: screen

func _ready():
	$AnimationPlayer.play("RESET")
	
func _process(delta: float) -> void:
	pauseMenu()
	if resume_game and not $AnimationPlayer.is_playing():
		get_tree().paused = false

func resume():
	resume_game = true
	$AnimationPlayer.play_backwards("blur")
	equip_menu.animation.play("RESET")
	
func pause():
	get_tree().paused = true
	resume_game = false
	default_button.grab_focus()
	updateStats()
	$AnimationPlayer.play("blur")
	
func updateStats():
	labels.LevelValue.text = str(Global.getStat("LV"))
	labels.LevelValue.text = ""
	labels.MainStatsValues.text = ""
	labels.MainStatsMaxValues.text = ""
	labels.SubStatValues.text = ""
	labels.BattleStatsValues.text = ""
	labels.LevelValue.text = str(Global.getStat("LV"))
	for stat in Global.getBasicStats():
		labels.SubStatValues.text += str(stat) + "\n"
	for stat in ["HP", "MP", "SP"]:
		labels.MainStatsValues.text += str(Global.getStat(stat)) + "\n"
		labels.MainStatsMaxValues.text += str(Global.getStat("M" + stat)) + "\n"
	for stat in ["ATK", "DEF"]:
		labels.BattleStatsValues.text += str(Global.getStat(stat)) + "\n"
	labels.ResourcesValues.text = str(Global.getStat("EXP")) + "\n"
	labels.ResourcesValues.text += "17\n"
	labels.ResourcesValues.text += str(Global.getStat("GOLD")) + "\n"
	
func pauseMenu():
	if Input.is_action_just_pressed("menu") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("menu") and get_tree().paused:
		resume()
