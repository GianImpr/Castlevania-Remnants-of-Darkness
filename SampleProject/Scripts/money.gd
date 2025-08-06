extends RigidBody2D
class_name Money
@export var type: CoinType
@export var sprite: Sprite2D
@export var animation: AnimationPlayer
var value: int
@export var sound: PolyphonicMenuAudio
@export var coin_data: Array[Coin]
@export var wall_checker: WallChecker
const HIGHEST_RANDOM_TYPE: CoinType = CoinType.Gold25
const LOWEST_RANDOM_TYPE: CoinType = CoinType.Gold1
var min_x: int
var local_collision_pos: Array[Vector2] = [Vector2(0, 0), Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]

const SPAWN_DELAY: int = 0.05

static var isInsideWall: Callable
static var sort_y: Callable
static var checkAndSortVertices: Callable

enum CoinType {
	Gold1,
	Gold5,
	Gold10,
	Gold25,
	Gold50,
	Gold100,
	Gold250,
	Gold500,
	Gold1000,
	Gold2000
}

func _ready() -> void:
	type = randi_range(LOWEST_RANDOM_TYPE, HIGHEST_RANDOM_TYPE)
	if Global.player.stats.Stats["LCK"] > randi_range(0, 99):
		type += 1
	if Global.player.stats.Stats["LCK"] > randi_range(0, 199):
		type += 1

	sprite.texture = coin_data[type].texture
	if type <= CoinType.Gold100:
		animation.play("coin")
		
func _on_area_2d_body_entered(body: Node2D) -> void:
	sound.play_sound_effect_from_library("collect")
	Global.item_box.changeColor(0)
	Global.item_box.visible = true
	Global.item_box.label.text = "$" + str(coin_data[type].value)
	Global.player.stats.Stats["GOLD"] += coin_data[type].value
	Global.item_box.timer.start()
	animation.play("picked")

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	wall_checker.checkAndSortVertices(state)
