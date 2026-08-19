extends Control

@onready var health: TextureProgressBar = $Bars/Health
@onready var max_health: TextureProgressBar = $Bars/MaxHealth
@onready var max_mana: TextureProgressBar = $Bars/MaxMana
@onready var mana: TextureProgressBar = $Bars/Mana
@onready var mana_border: TextureRect = $Bars/BorderMP
@onready var health_border: TextureRect = $Bars/BorderHP
@onready var focus: TextureProgressBar = $Focus
@onready var hearts: TextureProgressBar = $IDBody/Hearts
@onready var health_glow: TextureRect = $Bars/HGlow
@onready var mana_glow: TextureRect = $Bars/MGlow
@onready var heart_glow: TextureRect = $IDBody/HeartGlow
@onready var h_box_container: ImageNumber = $Numbers
@onready var player = Global.player
@onready var h_box_container_3: ImageNumber = $ImageNumber
@onready var id_body: TextureRect = $IDBody
@onready var id_skill: TextureRect = $IDBody/SkillIcon
@onready var boss_bar: TextureRect = $BossBar
@export var id_level_up_animation: AnimationPlayer
@export var guard_health: HBoxContainer

@export var mana_colors: Array[GradientTexture2D]

var can_change_opacity: bool = true
var is_transparent: bool = false
var opacity_trigger_offset: int = 0


var HP
var MHP
var MMP
var MP

func _ready():
	HP = player.stats.Stats["HP"]
	MHP = player.stats.Stats["MHP"]
	MP = player.stats.Stats["MP"]
	MMP = player.stats.Stats["MMP"]
	h_box_container.updateHP(HP, MHP)
	if Global.player.innocent_devil != null:
		h_box_container.updateHP(Global.player.innocent_devil.stats.Stats["Hearts"], Global.player.innocent_devil.stats.Stats["MHearts"])
		initBar(Global.player.innocent_devil.stats.Stats["Hearts"], Global.player.innocent_devil.stats.Stats["MHearts"], hearts)
	initBar(HP, MHP, health)
	initBar(MP, MMP, mana)
	
func _process(delta: float) -> void:
	HP = player.stats.Stats["HP"]
	MHP = player.stats.Stats["MHP"]
	MP = player.stats.Stats["MP"]
	MMP = player.stats.Stats["MMP"]
	health_glow.visible = HP <= MHP/4
	mana_glow.visible = MP < 30 and player.unlocked_magic
	mana.visible = player.unlocked_magic and player.isRelicEquipped()
	max_mana.visible = player.unlocked_magic and player.isRelicEquipped()
	mana_border.visible = player.unlocked_magic and player.isRelicEquipped()
	updateMaxStat(MHP, health, max_health, health_glow, health_border, true)
	updateMaxStat(MMP, mana, max_mana, mana_glow, mana_border, true)
	updateHP(delta)
	updateMP(delta)
	updateGuardHealth()
	
	var focus_animation: AnimationPlayer = focus.get_child(0)
	focus.value = player.stats.Stats["FP"]/player.stats.Stats["MFP"]*focus.max_value
	if player.stats.Stats["FP"] == player.stats.Stats["MFP"] and not focus_animation.current_animation == "full":
		focus_animation.play("full")
	elif player.stats.Stats["FP"] != player.stats.Stats["MFP"] and not focus_animation.current_animation == "not_full":
		focus_animation.play("not_full")

	if Global.player.innocent_devil != null:
		id_skill.texture = Global.player.innocent_devil.stats.skills[Global.player.innocent_devil.current_skill].icon
		updateHearts(delta)
		updateMaxStat(Global.player.innocent_devil.stats.Stats["MHearts"], hearts)
		heart_glow.visible = Global.player.innocent_devil.stats.Stats["Hearts"] <= Global.player.innocent_devil.stats.Stats["MHearts"]/4
	id_body.visible = Global.player.innocent_devil != null
	h_box_container_3.visible = Global.player.innocent_devil != null
	
	if Global.camera.limit_right - Global.camera.limit_left < 864:
		opacity_trigger_offset = 864 - (Global.camera.limit_right - Global.camera.limit_left)
	else:
		opacity_trigger_offset = 0
	
	if Global.player.position.x + opacity_trigger_offset <= size.x*0.7 and Global.player.position.y - Global.camera.limit_top <= size.y*0.7 and not isTransparent():
		setOpacity(0)
	elif (Global.player.position.x + opacity_trigger_offset > size.x*0.7 or Global.player.position.y - Global.camera.limit_top > size.y*0.7) and isTransparent():
		setOpacity(1)

func initBar(stat, maxStat, bar):
	bar.max_value = max(maxStat*10, 1)
	bar.value = stat*10
	
func updateHPNumber():
	h_box_container.updateHP(HP, MHP)
	h_box_container_3.updateHP(Global.player.innocent_devil.stats.Stats["Hearts"], Global.player.innocent_devil.stats.Stats["MHearts"])
	
func updateHP(delta):
	if health.value < HP*10:
		health.value = min(HP*10, health.value+ceil(5*MHP*delta))
		h_box_container.updateHP(int(health.value/10), MHP)
	elif health.value > HP*10:
		health.value = max(HP*10, health.value-ceil(5*MHP*delta))
		h_box_container.updateHP(int(health.value/10), MHP)
		
func updateMP(delta):
	match Global.player.stats.equipment["relic"]-1:
		Relic.Relics.INDIGO_CROSS:
			mana_glow.self_modulate = Color(0, 0.545, 0.898)
		Relic.Relics.AGUNIS_LAUREL:
			mana_glow.self_modulate = Color(1, 0.365, 0)
			
	mana.texture_progress = mana_colors[max(Global.player.stats.equipment["relic"]-1, 0)]
	if mana.value < MP*10:
		mana.value = min(MP*10, mana.value+ceil(5*MMP*delta))
	elif mana.value > MP*10:
		mana.value = max(MP*10, mana.value-ceil(5*MMP*delta))
		
func updateGuardHealth() -> void:
	if Global.player == null:
		return
	guard_health.visible = Global.player.stats.findItem(Skill.Skills.FORTITUDE_GAUNTLET, Global.player.stats.skill_inventory)
	var guard_recovery_timer: Timer = Global.player.guard_recovery
	var guard_hp: float = min(Global.player.stats.Stats["Guard"]+(guard_recovery_timer.wait_time-guard_recovery_timer.time_left)/guard_recovery_timer.wait_time, 3)
	for i in range(0, guard_health.get_child_count()-1):
		guard_health.get_child(i).self_modulate = Color(1,1,1, min(guard_hp-1-i, 1))
		guard_health.get_child(i).get_child(0).visible = min(guard_hp-1-i, 1) == 1
	
func updateHearts(delta):
	if hearts.value < Global.player.innocent_devil.stats.Stats["Hearts"]*10:
		hearts.value = min(Global.player.innocent_devil.stats.Stats["Hearts"]*10, hearts.value+ceil(5*Global.player.innocent_devil.stats.Stats["MHearts"]*delta))
		h_box_container_3.updateHP(int(hearts.value/10), Global.player.innocent_devil.stats.Stats["MHearts"])
	elif hearts.value > Global.player.innocent_devil.stats.Stats["Hearts"]*10:
		hearts.value = max(Global.player.innocent_devil.stats.Stats["Hearts"]*10, hearts.value-ceil(5*Global.player.innocent_devil.stats.Stats["MHearts"]*delta))
		h_box_container_3.updateHP(int(hearts.value/10), Global.player.innocent_devil.stats.Stats["MHearts"])

	
func updateMaxStat(stat, bar, max_bar = null, glow = null, border = null, resize: bool = false):
	const BASE_LENGTH: float = 2.5
	const ADDITIONAL_LENGTH: float = 5
	const MAX_VALUE: int = 999
	const BASE_VALUE: int = 100
	var bar_length: float = BASE_LENGTH+ADDITIONAL_LENGTH*(stat-BASE_VALUE)/(MAX_VALUE-BASE_VALUE)
	if resize:
		bar.scale.x = bar_length
		max_bar.scale.x = bar_length
		glow.scale.x = bar_length
		border.scale.x = bar_length
	bar.max_value = max(stat*10, 1)

func setOpacity(opacity: float) -> void:
	if not can_change_opacity:
		return
	can_change_opacity = false
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1,1,1,opacity), 0.1)
	await tween.finished
	can_change_opacity = true
	
func isTransparent() -> bool:
	return modulate.a < 1
