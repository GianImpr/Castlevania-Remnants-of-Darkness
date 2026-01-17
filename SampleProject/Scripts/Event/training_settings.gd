extends Node
class_name TrainingSettings

static var hearts_to_collect: int
static var remove_MP: bool
static var remove_hearts: bool
static var damage_upon_hit: int
static var can_deal_damage: bool
static var enemies: Array[PackedScene]
static var cur_challenge: TrainingMode.Training
static var HP_depletion_in: float
var result: ChallengeResult = ChallengeResult.NONE
static var collected_hearts: int = 0
static var heart_scene: PackedScene = preload("res://SampleProject/extra_scenes/items/heart.tscn")
@export var enemy_spawner: SpawnEnemy
@export var enemy_spawner_2: SpawnEnemy
static var player_global_position: Vector2
static var player_current_room: String
var HP_loss_tween: Tween 

enum ChallengeResult {
	NONE,
	WIN,
	LOSE
}

func _ready() -> void:
	enemy_spawner.enemy = enemies[0]
	if enemies.size() > 1:
		enemy_spawner_2.enemy = enemies[1]
		enemy_spawner_2.process_mode = Node.PROCESS_MODE_INHERIT
	enemy_spawner.process_mode = Node.PROCESS_MODE_INHERIT
	if HP_depletion_in > 0:
		HP_loss_tween = get_tree().create_tween()
		HP_loss_tween.tween_property(Global.player.stats, "Stats:HP", 0, HP_depletion_in)

func _process(delta: float) -> void:
	if result == ChallengeResult.NONE:
		if remove_MP:
			Global.player.stats.Stats["MP"] = 0
			
		if remove_hearts and Global.player.innocent_devil:
			Global.player.innocent_devil.stats.Stats["Hearts"] = 1
			
	if hearts_to_collect == collected_hearts and result == ChallengeResult.NONE:
		result = ChallengeResult.WIN
		if HP_loss_tween and HP_loss_tween.is_running():
			HP_loss_tween.kill()
		for enemy in get_parent().get_children():
			if enemy is Enemy:
				enemy.stats.HP = 0
		Global.tutorial_box.time = 2
		if Global.training_menu.trainings[cur_challenge-1].max_challenge_level != TrainingMode.TrainingLevel.ADVANCED:
			Global.tutorial_box.text = "[color=#00FF00]Challenge completed![/color]"
		else:
			Global.tutorial_box.text = "[color=#00FF00]Challenge completed![/color]\nObtained [color=#FFFF00]PRIZE[/color]"
		if Global.training_menu.trainings[cur_challenge-1].max_challenge_level == Global.training_menu.cur_challenge_level:
			Global.training_menu.trainings[cur_challenge-1].max_challenge_level = min(Global.training_menu.trainings[cur_challenge-1].max_challenge_level+1, 3)
		Global.tutorial_box.activate = true
		Global.player.state_machine.current_state.Transitioned.emit(Global.player.state_machine.current_state, "wait")
		get_tree().create_timer(2.5, true).timeout.connect(returnToTrainingMenu)
		Global.player.is_hurt = false
		
	if Global.player.stats.Stats["HP"] <= 0 and result == ChallengeResult.NONE:
		Global.tutorial_box.time = 2
		Global.tutorial_box.text = "[color=#FF0000]Challenge failed...[/color]"
		Global.tutorial_box.activate = true
		result = ChallengeResult.LOSE
		get_tree().create_timer(2.5, true).timeout.connect(returnToTrainingMenu)

static func _spawnHeart(custom_position: Vector2) -> void:
	var heart = heart_scene.instantiate()
	heart.fly_high = true
	if custom_position == Vector2.ZERO:
		heart.global_position = Global.player.global_position+Vector2(0,-30)
	else:
		heart.global_position = custom_position
	MetSys.get_current_room_instance().call_deferred("add_child", heart)


## Spawns a heart if the current training mode is being played.
static func spawnTrainingHeart(cur_training: TrainingMode.Training, custom_position: Vector2 = Vector2.ZERO) -> void:
	if Global.screen == Global.ScreenType.TRAINING and TrainingSettings.cur_challenge == cur_training:
		_spawnHeart(custom_position)

func returnToTrainingMenu() -> void:
	Global.player.stats.Stats["HP"] = Global.player.stats.Stats["MHP"]
	Global.player.stats.Stats["MP"] = Global.player.stats.Stats["MMP"]
	Global.player.heal_innocent(9999)
	Global.player.is_hurt = false
	Global.player.velocity = Vector2.ZERO
	Global.player.state_machine.current_state.Transitioned.emit(Global.player.state_machine.current_state, "idle")
	get_tree().paused = true
	await Global.total_fade_screen.fadeOutFor(0.5)
	Global.change_area.emit(player_current_room, player_global_position)
	Global.training_menu.openMenu()
	await Global.total_fade_screen.fadeInFor(2.5)
