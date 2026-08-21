extends Control
class_name GoldHUD

@export var gold_value: Label
@export var increased_gold_value: Label
@export var increased_gold_icon: TextureRect
@export var gold_icons: Array[CompressedTexture2D]
var displayed_gold_value: int = -1
var collected_gold: int = 0
var collect_gold_tween: Tween
var modulate_tween: Tween
const COLLECT_AFTER_SECONDS: float = 2
const MODULATE_SPEED_SECONDS: float = 0.2
const COLLECTION_DURATION: float = 0.1
const FADE_AFTER_SECONDS: float = 1
var collect_gold_caller_id: int = 0

const GOLD_ICON_THRESHOLDS := [
	1,
	25,
	50,
	100,
	250,
	400,
	1000,
	2000
]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	gold_value.text = str(displayed_gold_value)
	increased_gold_value.text = "+" + str(collected_gold)
	
func collectGold() -> void:
	collect_gold_caller_id += 1
	var call_id: int = collect_gold_caller_id
	
	if displayed_gold_value == -1:
		displayed_gold_value = Global.player.stats.Stats["GOLD"]
	
	if collect_gold_tween != null and collect_gold_tween.is_running():
		collect_gold_tween.kill()
		modulate_tween.kill()
		
	collected_gold = Global.player.stats.Stats["GOLD"]-displayed_gold_value
	increased_gold_value.text = str(collected_gold)
	increased_gold_value.visible = true
	increased_gold_icon.texture = gold_icons[determineGoldIcon(collected_gold)]
	var total_gold_collected: int = collected_gold
	
	modulate_tween = get_tree().create_tween()
	modulate_tween.tween_property(self, "modulate", Color.WHITE, MODULATE_SPEED_SECONDS)
	await get_tree().create_timer(COLLECT_AFTER_SECONDS).timeout
	if call_id != collect_gold_caller_id:
		return

	collect_gold_tween = get_tree().create_tween()
	collect_gold_tween.set_parallel()
	collect_gold_tween.tween_property(self, "collected_gold", 0, max(log(total_gold_collected/10)/5, 0.1))
	collect_gold_tween.tween_property(self, "displayed_gold_value", Global.player.stats.Stats["GOLD"], max(log(total_gold_collected/10)/5, 0.1))
	await collect_gold_tween.finished
	if call_id != collect_gold_caller_id:
		return
	increased_gold_value.visible = false
	
	await get_tree().create_timer(FADE_AFTER_SECONDS).timeout
	if call_id != collect_gold_caller_id:
		return
	modulate_tween = get_tree().create_tween()
	modulate_tween.tween_property(self, "modulate", Color.TRANSPARENT, MODULATE_SPEED_SECONDS)

func determineGoldIcon(value: int) -> int:
	for i in range(0, GOLD_ICON_THRESHOLDS.size()):
		if value < GOLD_ICON_THRESHOLDS[i]:
			return i-1
			
	return GOLD_ICON_THRESHOLDS.size()-1
