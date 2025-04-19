extends Control

@onready var health: TextureProgressBar = $TextureRect/Health
@onready var mana: TextureProgressBar = $TextureRect/Mana
@onready var hearts: TextureProgressBar = $IDBody/Hearts
@onready var health_glow: TextureRect = $TextureRect/HGlow
@onready var mana_glow: TextureRect = $TextureRect/MGlow
@onready var heart_glow: TextureRect = $IDBody/HeartGlow
@onready var h_box_container: ImageNumber = $HBoxContainer
@onready var player = Global.player
@onready var h_box_container_2: ImageNumber = $HBoxContainer2
@onready var h_box_container_3: ImageNumber = $ImageNumber
@onready var id_body: TextureRect = $IDBody
@onready var id_skill: TextureRect = $IDBody/SkillIcon
@onready var boss_bar: TextureRect = $BossBar
@export var id_level_up_animation: AnimationPlayer
@export var guard_health: HBoxContainer
var can_change_opacity: bool = true
var is_transparent: bool = false
var opacity_trigger_offset: int = 0


var HP
var MHP
var MMP
var MP

func _ready():
	Global.HUD = self
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
	updateMaxStat(MHP, health)
	updateMaxStat(MMP, mana)
	updateHP(delta)
	updateMP(delta)
	updateGuardHealth()
	if Global.player.innocent_devil != null:
		id_skill.texture = Global.player.innocent_devil.stats.skills[Global.player.innocent_devil.current_skill].icon
		updateHearts(delta)
		updateMaxStat(Global.player.innocent_devil.stats.Stats["MHearts"], hearts)
		heart_glow.visible = Global.player.innocent_devil.stats.Stats["Hearts"] <= Global.player.innocent_devil.stats.Stats["MHearts"]/4
	id_body.visible = Global.player.innocent_devil != null
	h_box_container_3.visible = Global.player.innocent_devil != null
	h_box_container_2.updateGuard()
	
	if Global.camera.limit_right - Global.camera.limit_left < 864:
		opacity_trigger_offset = 864 - (Global.camera.limit_right - Global.camera.limit_left)
	else:
		opacity_trigger_offset = 0
	
	if Global.player.position.x + opacity_trigger_offset <= size.x*0.7 and Global.player.position.y - Global.camera.limit_top <= size.y*0.7 and not isTransparent():
		setOpacity(0.3)
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
	if mana.value < MP*10:
		mana.value = min(MP*10, mana.value+ceil(5*MMP*delta))
	elif mana.value > MP*10:
		mana.value = max(MP*10, mana.value-ceil(5*MMP*delta))
		
func updateGuardHealth() -> void:
	if Global.player == null:
		return
	guard_health.visible = Global.player.stats.findItem(1, Global.player.stats.skill_inventory)
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

	
func updateMaxStat(stat, bar):
	bar.max_value = max(stat*10, 1)

func setOpacity(opacity: float) -> void:
	if not can_change_opacity:
		return
	can_change_opacity = false
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1,1,1,opacity), 0.2)
	await tween.finished
	can_change_opacity = true
	
func isTransparent() -> bool:
	return modulate.a < 1
