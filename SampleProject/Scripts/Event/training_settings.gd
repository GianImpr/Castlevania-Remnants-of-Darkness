extends Node
class_name TrainingSettings

static var hearts_to_collect: int
static var remove_MP: bool
static var remove_hearts: bool
static var damage_upon_hit: int
static var can_deal_damage: bool
static var enemies: Array[PackedScene]
static var cur_challenge: TrainingMode.Training
var result: ChallengeResult = ChallengeResult.NONE
var collected_hearts: int = 0
static var heart_scene: PackedScene = preload("res://SampleProject/extra_scenes/items/heart.tscn")

enum ChallengeResult {
	NONE,
	WIN,
	LOSE
}

func _process(delta: float) -> void:
	if result == ChallengeResult.NONE:
		if remove_MP:
			Global.player.stats.Stats["MP"] = 0
			
		if remove_hearts and Global.player.innocent_devil:
			Global.player.innocent_devil.stats.Stats["Hearts"] = 1
			
	if hearts_to_collect == collected_hearts:
		result = ChallengeResult.WIN
		
	if Global.player.stats.Stats["HP"] == 0 and result == ChallengeResult.NONE:
		result = ChallengeResult.LOSE
		
static func _spawnHeart() -> void:
	var heart = heart_scene.instantiate()
	heart.fly_high = true
	heart.global_position = Global.player.global_position+Vector2(0,-20)
	MetSys.get_current_room_instance().call_deferred("add_child", heart)


## Spawns a heart if the current training mode is being played.
static func spawnTrainingHeart(cur_training: TrainingMode.Training) -> void:
	if Global.screen == Global.ScreenType.TRAINING and TrainingSettings.cur_challenge == cur_training:
		_spawnHeart()
