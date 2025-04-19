extends TextureRect

@export var animation: AnimationPlayer
var enemy: Enemy:
	set(value):
		enemy = value
		prepareBar(enemy)
		
@export var yellow_bar: TextureProgressBar
@export var blue_bar: TextureProgressBar
@export var yellow_damage: TextureProgressBar
@export var blue_damage: TextureProgressBar
@export var damage_display_duration: Timer
var displayed_HP: int = 0
var displayed_MHP: int = 1
var damage_deplete_tween: Tween

func _ready():
	visible = false
	Global.boss_bar = self
	
func prepareBar(body: Enemy):
	displayed_HP = body.stats.HP
	displayed_MHP = body.stats.HP
	animation.play("initialize")
	
func _process(delta: float) -> void:
	if enemy == null and visible:
		animation.play("vanish")
	if enemy == null:
		return
	if displayed_HP > enemy.stats.HP:
		displayed_HP = enemy.stats.HP
		animation.play("shake")
		damage_display_duration.start()
		updateBar()
		
		
func updateBar():
	yellow_bar.value = float(displayed_HP)/(displayed_MHP/2)*yellow_bar.max_value
	blue_bar.value = float(displayed_HP-displayed_MHP/2)/(displayed_MHP/2)*blue_bar.max_value


func _on_damage_display_timeout() -> void:
	if blue_bar.value < blue_damage.value:
		damage_deplete_tween = get_tree().create_tween()
		damage_deplete_tween.set_ease(Tween.EaseType.EASE_OUT)
		damage_deplete_tween.tween_property(blue_damage, "value", blue_bar.value, 0.5)
		await damage_deplete_tween.finished
	if yellow_bar.value < yellow_damage.value:
		damage_deplete_tween = get_tree().create_tween()
		damage_deplete_tween.set_ease(Tween.EaseType.EASE_OUT)
		damage_deplete_tween.tween_property(yellow_damage, "value", yellow_bar.value, 0.5)
