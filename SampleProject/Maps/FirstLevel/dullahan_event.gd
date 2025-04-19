extends CombatScene
@export var dullahan: Dullahan
@export var orb: Orb
var music_playing: bool = false

func _ready() -> void:
	super()
	if Global.player.stats.combat_flags[event_ID]:
		dullahan.queue_free()

func _process(delta: float) -> void:
	if dullahan != null and dullahan.state_machine.current_state is DullahanAppearing:
		playMusic("boss1")
		music_playing = true
		
	if dullahan == null and not Global.player.stats.combat_flags[event_ID] and (orb != null and not orb.spawned):
		await _dissolveMusic()
		await orb._spawnOrb()
		
	if orb == null and Global.screen == Global.ScreenType.NONE:
		#Global.player.stats.combat_flags[event_ID] = true
		thanksScreen()
		#queue_free()

func thanksScreen() -> void:
	Global.screen = Global.ScreenType.EVENT
	Global.player.freeze()
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(Global.fade_screen, "modulate", Color(1,1,1,1), 1)
	await tween.finished
	Global.stage_presentation.play("Thank you for playing")
	await Global.stage_presentation.animation.animation_finished
	Global.toTitleScreen()
