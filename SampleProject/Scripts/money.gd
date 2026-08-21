extends RigidBody2D
class_name Money
@export var type: CoinType
@export var sprite: Sprite2D
@export var animation: AnimationPlayer
var value: int
@export var sound: PolyphonicMenuAudio
@export var coin_data: Array[Coin]
@export var wall_checker: WallChecker
@export var collision: CollisionShape2D
const HIGHEST_RANDOM_TYPE: CoinType = CoinType.Gold25
const LOWEST_RANDOM_TYPE: CoinType = CoinType.Gold1

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
		
	if Global.player.stats.accessoryEquipped(Accessory.Accessories.GOLD_RING):
		type = min(type+1, CoinType.Gold100)

	sprite.texture = coin_data[type].texture
	if type <= CoinType.Gold100:
		animation.play("coin")
		
func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_parent() is TileMapLayer:
		return 
	sound.play_sound_effect_from_library("collect")
	#Global.item_box.addEntry("$" + str(coin_data[type].value), ItemBox.Type.BLUE, null)
	Global.player.stats.Stats["GOLD"] += coin_data[type].value
	Global.HUD.gold_HUD.collectGold()
	animation.play("picked")
