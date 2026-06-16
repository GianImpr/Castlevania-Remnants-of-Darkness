extends Control
class_name HeadsUpDisplay

@onready var health: TextureProgressBar = $TextureRect/Health
@onready var mana: TextureProgressBar = $TextureRect/Mana
@onready var focus: TextureProgressBar = $TextureRect/Focus
@onready var hearts: TextureProgressBar = $IDBars/Hearts
@onready var h_box_container: ImageNumber = $HBoxContainer
@onready var player = Global.player
@onready var h_box_container_2: ImageNumber = $HBoxContainer2
@onready var h_box_container_3: ImageNumber = $ImageNumber
@onready var id_body: TextureRect = $IDBars
@onready var id_skill: TextureRect = $IDBars/SkillIcon
@onready var boss_bar: BossBar = $BossBar
@onready var boss_bar_2: BossBar = $Control/BossBar2
@export var id_level_up_animation: AnimationPlayer
@export var guard_health: HBoxContainer
@onready var training: Control = $Training
@onready var training_number: ImageNumber = $Training/TrainingNumber
@onready var training_max_number: ImageNumber = $Training/TrainingMaxNumber
@onready var weapon_icon: TextureRect = $WeaponIcon
@onready var hud_body: PanelContainer = $Body
@onready var id_hud_body: PanelContainer = $IDBody
@export var mana_colors: Array[CompressedTexture2D]
@onready var HUD_fog: TextureRect = $TextureRect/Fog
@onready var id_hud_fog: TextureRect = $TextureRect/IDFog
@onready var id_mode: TextureRect = $IDBars/IDMode

var can_change_opacity: bool = true
var is_transparent: bool = false
var opacity_trigger_offset: int = 0
var id_mode_tween_color: Tween

const BASE_BAR_SIZE: int = 48
const MAX_BAR_SIZE: int = 130
const BASE_BODY_SIZE: int = 140
const DEFAULT_BODY_SIZE: int = 163
const ID_OFFENSIVE_MODE_COLOR: Color = Color.RED
const ID_DEFENSIVE_MODE_COLOR: Color = Color.DODGER_BLUE
const ID_MODE_SWITCH_TWEEN_DURATION: float = 0.25
const ID_NO_MODE_COLOR: Color = Color.BLACK

const ID_BASE_BAR_SIZE: int = 33
const ID_MAX_BAR_SIZE: int = 90
const ID_BASE_BODY_SIZE: int = 98
const ID_DEFAULT_BODY_SIZE: int = 105
const ID_FOG_BASE_SIZE: int = 116

const FOG_BASE_BODY_SIZE: int = 170

var HP
var MHP
var MMP
var MP
var low_MP_tint: Color
var cur_low_MP_tint: int
const low_HP_tint: Color = Color.RED
const low_Hearts_tint: Color = Color(0.886, 0.0, 0.796)
var blinking_tweens: Array[Tween] = [null, null, null]
var fog_tween: Tween
var initialize_bars_instantly: int = 0

enum BLINKING_TWEEN {
	HP,
	MP,
	HEARTS
}


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
	else:
		Global.HUD.id_mode.self_modulate = Global.HUD.ID_NO_MODE_COLOR
	initBar(HP, MHP, health)
	initBar(MP, MMP, mana)
	var atlas: AtlasTexture = HUD_fog.texture
	var id_atlas: AtlasTexture = id_hud_fog.texture
	fog_tween = get_tree().create_tween()
	fog_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	fog_tween.set_loops()
	fog_tween.set_parallel()
	fog_tween.tween_property(atlas, "region:position:x", 0, 10).from(256)
	fog_tween.tween_property(id_atlas, "region:position:x", 0, 10).from(256)
	
func _process(delta: float) -> void:
	HP = player.stats.Stats["HP"]
	MHP = player.stats.Stats["MHP"]
	MP = player.stats.Stats["MP"]
	MMP = player.stats.Stats["MMP"]
	#health_glow.visible = HP <= MHP/4
	#mana_glow.visible = MP < 30 and player.unlocked_magic
	mana.visible = player.unlocked_magic and Global.player.stats.equipment["relic"] > 0
	updateMaxStat(MHP, health, delta)
	updateMaxStat(MMP, mana, delta)
	updateBodySize()
	updateHP(delta)
	updateMP(delta)
	updateGuardHealth()
	checkBlinking(HP, MHP, health, BLINKING_TWEEN.HP, low_HP_tint)
	checkBlinking(MP, MMP, mana, BLINKING_TWEEN.MP, low_MP_tint)
	
	var focus_animation: AnimationPlayer = focus.get_child(0)
	focus.value = player.stats.Stats["FP"]/player.stats.Stats["MFP"]*focus.max_value
	if player.stats.Stats["FP"] == player.stats.Stats["MFP"] and not focus_animation.current_animation == "full":
		focus_animation.play("full")
	elif player.stats.Stats["FP"] != player.stats.Stats["MFP"] and not focus_animation.current_animation == "not_full":
		focus_animation.play("not_full")

	if Global.player.innocent_devil != null and not Global.screen == Global.ScreenType.TRAINING:
		id_skill.texture = Global.player.innocent_devil.stats.skills[Global.player.innocent_devil.current_skill].icon
		updateMaxStat(Global.player.innocent_devil.stats.Stats["MHearts"], hearts, delta, true)
		updateHearts(delta)
		updateIDBodySize()
		checkBlinking(Global.player.innocent_devil.stats.Stats["Hearts"], Global.player.innocent_devil.stats.Stats["MHearts"], hearts, BLINKING_TWEEN.HEARTS, low_Hearts_tint)
		#heart_glow.visible = Global.player.innocent_devil.stats.Stats["Hearts"] <= Global.player.innocent_devil.stats.Stats["MHearts"]/4
	training.visible = Global.screen == Global.ScreenType.TRAINING
	if training.visible:
		training_number.printNumber(TrainingSettings.collected_hearts)
		training_max_number.printNumber(TrainingSettings.hearts_to_collect)
	id_body.visible = Global.player.innocent_devil != null and not Global.screen == Global.ScreenType.TRAINING
	id_hud_body.visible = id_body.visible
	id_hud_fog.visible = id_body.visible
	h_box_container_3.visible = Global.player.innocent_devil != null and not Global.screen == Global.ScreenType.TRAINING
	h_box_container_2.updateGuard()
	
	if Global.camera.limit_right - Global.camera.limit_left < 864:
		opacity_trigger_offset = 864 - (Global.camera.limit_right - Global.camera.limit_left)
	else:
		opacity_trigger_offset = 0
	
	if Global.player.position.x + opacity_trigger_offset <= hud_body.size.x*2 and Global.player.position.y - Global.camera.limit_top <= hud_body.size.y*2 and not isTransparent():
		setOpacity(0.2)
	elif (Global.player.position.x + opacity_trigger_offset > hud_body.size.x*2 or Global.player.position.y - Global.camera.limit_top > hud_body.size.y*2) and isTransparent():
		setOpacity(1)

func initBar(stat, maxStat, bar):
	bar.max_value = max(maxStat*10, 1)
	bar.value = stat*10
	
func updateHPNumber():
	h_box_container.updateHP(HP, MHP)
	h_box_container_3.updateHP(Global.player.innocent_devil.stats.Stats["Hearts"], Global.player.innocent_devil.stats.Stats["MHearts"])
	
func updateHP(delta):
	if not (Global.screen == Global.ScreenType.NONE or Global.screen == Global.ScreenType.WHEEL or Global.screen == Global.ScreenType.EVENT or Global.screen == Global.ScreenType.TRAINING):
		return
		
	if initialize_bars_instantly:
		health.value = HP*10
		h_box_container.updateHP(int(health.value/10), MHP)
		initialize_bars_instantly -= 1
		return
		
	if health.value < HP*10:
		health.value = min(HP*10, health.value+ceil(5*MHP*delta))
		h_box_container.updateHP(int(health.value/10), MHP)
	elif health.value > HP*10:
		health.value = max(HP*10, health.value-ceil(5*MHP*delta))
		h_box_container.updateHP(int(health.value/10), MHP)
		
func updateMP(delta):
	if Global.player.stats.equipment["relic"]-1 != cur_low_MP_tint and blinking_tweens[BLINKING_TWEEN.MP]:
		cur_low_MP_tint = Global.player.stats.equipment["relic"]-1
		blinking_tweens[BLINKING_TWEEN.MP].kill()
		
	match Global.player.stats.equipment["relic"]-1:
		Relic.Relics.INDIGO_CROSS:
			low_MP_tint = Color(0, 0.545, 0.898)
		Relic.Relics.AGUNIS_LAUREL:
			low_MP_tint = Color(1, 0.365, 0)
			
	mana.texture_progress = mana_colors[Global.player.stats.equipment["relic"]]
	if not (Global.screen == Global.ScreenType.NONE or Global.screen == Global.ScreenType.WHEEL or Global.screen == Global.ScreenType.EVENT or Global.screen == Global.ScreenType.TRAINING):
		return
		
	if initialize_bars_instantly:
		mana.value = MP*10
		initialize_bars_instantly -= 1
		return

	if mana.value < MP*10:
		mana.value = min(MP*10, mana.value+ceil(5*MMP*delta))
	elif mana.value > MP*10:
		mana.value = max(MP*10, mana.value-ceil(5*MMP*delta))
		
func updateGuardHealth() -> void:
	if Global.player == null:
		return
	if not (Global.screen == Global.ScreenType.NONE or Global.screen == Global.ScreenType.WHEEL or Global.screen == Global.ScreenType.EVENT or Global.screen == Global.ScreenType.TRAINING):
		return
	guard_health.visible = Global.player.stats.findItem(Skill.Skills.FORTITUDE_GAUNTLET, Global.player.stats.skill_inventory)
	var guard_recovery_timer: Timer = Global.player.guard_recovery
	var guard_hp: float = min(Global.player.stats.Stats["Guard"]+(guard_recovery_timer.wait_time-guard_recovery_timer.time_left)/guard_recovery_timer.wait_time, 3)
	if Global.player.stats.status[Global.player.stats.Status.ENFEEBLE] > 0:
		guard_hp = 0
	for i in range(0, guard_health.get_child_count()-1):
		guard_health.get_child(i).self_modulate = Color(1,1,1, min(guard_hp-1-i, 1))
		guard_health.get_child(i).get_child(0).visible = min(guard_hp-1-i, 1) == 1
	
func updateHearts(delta):
	if not (Global.screen == Global.ScreenType.NONE or Global.screen == Global.ScreenType.WHEEL or Global.screen == Global.ScreenType.EVENT):
		return
		
	if initialize_bars_instantly:
		hearts.value = Global.player.innocent_devil.stats.Stats["Hearts"]*10
		h_box_container_3.updateHP(int(hearts.value/10), Global.player.innocent_devil.stats.Stats["MHearts"])
		initialize_bars_instantly -= 1
		return

	if hearts.value < Global.player.innocent_devil.stats.Stats["Hearts"]*10:
		hearts.value = min(Global.player.innocent_devil.stats.Stats["Hearts"]*10, hearts.value+ceil(5*Global.player.innocent_devil.stats.Stats["MHearts"]*delta))
		h_box_container_3.updateHP(int(hearts.value/10), Global.player.innocent_devil.stats.Stats["MHearts"])
	elif hearts.value > Global.player.innocent_devil.stats.Stats["Hearts"]*10:
		hearts.value = max(Global.player.innocent_devil.stats.Stats["Hearts"]*10, hearts.value-ceil(5*Global.player.innocent_devil.stats.Stats["MHearts"]*delta))
		h_box_container_3.updateHP(int(hearts.value/10), Global.player.innocent_devil.stats.Stats["MHearts"])

	
func updateMaxStat(stat, bar, delta, id_stat: bool = false):
	if not (Global.screen == Global.ScreenType.NONE or Global.screen == Global.ScreenType.WHEEL or Global.screen == Global.ScreenType.EVENT):
		return
		
	if initialize_bars_instantly > 0:
		bar.max_value = max(stat*10, 1)
		initialize_bars_instantly -= 1
		return

	if bar.max_value < stat*10:
		bar.max_value = min(stat*10, bar.max_value+ceil(stat*5*delta))
	elif bar.max_value > stat*10:
		bar.max_value = max(stat*10, bar.max_value-ceil(stat*5*delta))
	if not id_stat:
		bar.size.x = BASE_BAR_SIZE*min(lerpf(1, 2.6, float(bar.max_value/10)/999), 2.6)
	else:
		bar.size.x = ID_BASE_BAR_SIZE*min(lerpf(1, 2.6, float(bar.max_value/10)/999), 2.6)
	
func updateBodySize():
	var higher_bar_length = max(health.size.x, mana.size.x)
	hud_body.size.x = BASE_BODY_SIZE-BASE_BAR_SIZE+higher_bar_length
	(HUD_fog.texture as AtlasTexture).region.size.x = FOG_BASE_BODY_SIZE+(hud_body.size.x-BASE_BODY_SIZE)*2
	HUD_fog.size.x = HUD_fog.texture.region.size.x
	
func updateIDBodySize():
	id_hud_body.size.x = ID_BASE_BODY_SIZE-ID_BASE_BAR_SIZE+hearts.size.x
	(id_hud_fog.texture as AtlasTexture).region.size.x = ID_FOG_BASE_SIZE+(id_hud_body.size.x-ID_BASE_BODY_SIZE)*2
	id_hud_fog.size.x = id_hud_fog.texture.region.size.x

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

func checkBlinking(stat, max_stat, bar: TextureProgressBar, tween_idx: int, color: Color) -> void:
	if stat <= max_stat / 4 and (blinking_tweens[tween_idx] == null or not blinking_tweens[tween_idx].is_running()):
		blinking_tweens[tween_idx] = get_tree().create_tween()
		blinking_tweens[tween_idx].set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		blinking_tweens[tween_idx].set_loops()
		blinking_tweens[tween_idx].tween_property(bar, "tint_under", color, 0.35)
		blinking_tweens[tween_idx].tween_property(bar, "tint_under", Color.WHITE, 0.35)
	elif stat > max_stat / 4 and blinking_tweens[tween_idx] != null and blinking_tweens[tween_idx].is_running():
		blinking_tweens[tween_idx].kill()
		bar.tint_under = Color.WHITE
		

## Updates the weapon icon in the HUD on top of the Focus bar and changes joypad's light color
## according to the current weapon type used.
func updateWeaponIconAndLight(weapon: Weapon) -> void:
	if weapon == null:
		if Input.has_joy_light(0):
			weapon_icon.texture = null
			Input.set_joy_light(0, Color.YELLOW)
			return
	
	if weapon:
		weapon_icon.texture = weapon.icon
	else:
		weapon_icon.texture = null

	if not Input.has_joy_light(0):
		return
	match weapon.type:
		Weapon.Type.SWORD:
			Input.set_joy_light(0, Color.RED)
		Weapon.Type.GREATSWORD:
			Input.set_joy_light(0, Color.ORANGE)
		Weapon.Type.AXE:
			Input.set_joy_light(0, Color.BLUE)
		Weapon.Type.SPEAR:
			Input.set_joy_light(0, Color.GREEN)
		Weapon.Type.FIST:
			Input.set_joy_light(0, Color.YELLOW)

func switchIdModeColor(color: Color) -> void:
	const MAX_INTENSITY_MULTIPLIER: float = 2
	if id_mode_tween_color != null and id_mode_tween_color.is_running():
		id_mode_tween_color.kill()
	id_mode_tween_color = get_tree().create_tween()
	id_mode_tween_color.tween_property(id_mode, "self_modulate", color*MAX_INTENSITY_MULTIPLIER, ID_MODE_SWITCH_TWEEN_DURATION)
	id_mode_tween_color.tween_property(id_mode, "self_modulate", color, ID_MODE_SWITCH_TWEEN_DURATION)
