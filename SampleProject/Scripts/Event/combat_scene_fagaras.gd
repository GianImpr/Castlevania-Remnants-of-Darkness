extends CombatScene
class_name Gauntlet
@export var armor_lord: PackedScene
var spawned_lord: bool = false
@export var spawn_enemy: PackedScene
var spawn
var cur_phase: int = 0
const PHASES: int = 6

func _ready() -> void:
	super()
	get_tree().create_timer(3).timeout.connect(_on_timer_timeout)

	
func _process(delta: float) -> void:
	var spawns_left = 0
	var enemies_left = 0
	if cur_phase < PHASES:
		for child in get_child(cur_phase).get_children():
			if child is SpawnEnemy:
				spawns_left += 1
			elif child is HardModeOnly:
				for stuff in child.get_children():
					if stuff is SpawnEnemy:
						spawns_left += 1
		for child in get_child(cur_phase).get_children():
			if child is Enemy:
				enemies_left += 1
			elif child is HardModeOnly:
				for stuff in child.get_children():
					if stuff is Enemy:
						enemies_left += 1
		if spawns_left == 0 and enemies_left == 0:
			cur_phase += 1
			if cur_phase < PHASES:
				get_child(cur_phase).process_mode = Node.PROCESS_MODE_INHERIT
		
	elif not Global.player.stats.combat_flags[event_ID]:
		Global.player.stats.combat_flags[event_ID] = true
		_dissolveMusic()
		


func _on_timer_timeout() -> void:
	get_child(cur_phase).process_mode = Node.PROCESS_MODE_INHERIT
	playMusic("encounter")
