extends CharacterBody2D
class_name Faerie
var facing_position: int = -1

var funny_wall_destination: Vector2
var wall_event_id: int = 0

@export var id: int = 1
@export var id_name: String
@export var stats: InnocentDevilStats
@export var state_machine: Node
var current_skill: Ability = Ability.HEAL

enum Ability {
	HEAL,
	REFRESHING_AIR
}

func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	if stats.Stats["EXP"] >= stats.expNeededToLvUp() and stats.Stats["LV"] < 99:
		stats.levelUp()
		
	if Input.is_action_just_pressed("next_skill"):
		current_skill = (current_skill+1)%stats.skills.size()
	elif Input.is_action_just_pressed("previous_skill"):
		current_skill = (current_skill-1)%stats.skills.size()
		
func _physics_process(delta: float) -> void:
	move_and_slide()

func createInnocentDevilEntry() -> InnocentDevilEntry:
	var entry: InnocentDevilEntry = InnocentDevilEntry.new()
	entry.getDataFromIDStats(self)
	return entry
	
func updateStatsInEntry() -> void:
	for entry in Global.player.innocent_devil_pocket:
		if entry.id == id:
			entry.updateStats(self)
			return
